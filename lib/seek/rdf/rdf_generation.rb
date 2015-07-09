require 'csv'


module Seek
  module Rdf
    module RdfGeneration
      include RdfRepositoryStorage
      include RightField

      def self.included(base)
        base.after_save :create_rdf_generation_job
        base.before_destroy :remove_rdf
      end

      def to_rdf
        rdf_graph = to_rdf_graph
        RDF::Writer.for(:rdfxml).buffer(:prefixes=>ns_prefixes) do |writer|
          rdf_graph.each_statement do |statement|
            writer << statement
          end
        end
      end

      def to_rdf_graph
        rdf_graph = handle_rightfield_contents self
        rdf_graph = describe_type(rdf_graph)
        rdf_graph = generate_from_csv_definitions rdf_graph
        rdf_graph = additional_triples rdf_graph
        rdf_graph = parse_spreadsheet rdf_graph
        rdf_graph
      end

      def handle_rightfield_contents object
        graph = nil
        if (object.respond_to?(:contains_extractable_spreadsheet?) && object.contains_extractable_spreadsheet?)
          begin
            graph = generate_rightfield_rdf_graph(self)
          rescue Exception=>e
            Rails.logger.error "Error generating RightField part of rdf for #{object} - #{e.message}"
          end
        end
        graph || RDF::Graph.new
      end

      def rdf_resource
        uri = Seek::Config.site_base_host+"/#{self.class.name.tableize}/#{self.id}"
        RDF::Resource.new(uri)
      end


      #extra steps that cannot be easily handled by the csv template
      def additional_triples rdf_graph
        if self.is_a?(Model) && self.contains_sbml?
          rdf_graph << [self.rdf_resource,JERMVocab.hasFormat,JERMVocab.SBML_format]
        end
        rdf_graph
      end

      def generate_from_csv_definitions rdf_graph
        #load template
        path_to_template=File.join(File.dirname(__FILE__), "rdf_mappings.csv")
        rows = Rails.cache.fetch("rdf_definitions",:expires_in=>1.hour) do
          CSV.read(path_to_template)
        end
        rows.each do |row|
          unless row[0].downcase=="class"
            klass=row[0].strip
            method=row[1]
            property=row[2]
            uri_or_literal=row[3].downcase
            transform=row[4]
            collection_transform=row[5]
            if (klass=="*" || self.class.name==klass) && self.respond_to?(method)
              rdf_graph = generate_triples(self,method,property,uri_or_literal,transform,collection_transform,rdf_graph)
            elsif self.class.name==klass #matched the class but the method isnt found
              puts "WARNING: Expected to find method #{method} for class #{klass}"
            end
          end
        end
        rdf_graph
      end

      def generate_triples subject, method, property,uri_or_literal,transformation,collection_transform,rdf_graph
        resource = subject.rdf_resource
        transform = transformation.strip unless transformation.nil?
        collection_transform = collection_transform.strip unless collection_transform.nil?
        items = subject.send(method)
        items = [items] unless items.kind_of?(Array) #may be an array of items or a single item. Cant use Array(item) here cos it screws up timezones and strips out nils
        unless collection_transform.blank?
          items = eval("items.#{collection_transform}")
        end
        items.each do |item|
          property_uri = eval(property)
          if !transformation.blank?
            item = eval(transformation)
          end
          o = if uri_or_literal.downcase=="u"
                if item.respond_to?(:rdf_resource)
                  item.rdf_resource
                else
                  uri = RDF::URI.new(item)
                  begin
                    uri.validate!
                  rescue
                    nil
                  end
                end
          else
            item.nil? ? "" : item
          end
          unless o.nil?
            rdf_graph << [resource,property_uri,o]
          end

        end
        rdf_graph
      end

      def parse_spreadsheet rdf_graph
        if self.is_a? DataFile
          if (self.respond_to?(:contains_extractable_spreadsheet?) && self.contains_extractable_spreadsheet?)
            #TODO test if spreadsheet is swains
            reader = PlatemapReader.new
            samples = reader.read_in(self) #[[nil, 'Raf'],[nil, 'Gal'],['WT', 'Raf']...]
            sample_no = 1
            samples.each do |sample|
              strain = sample.first
              sugar = sample.second
              sample_to_triple(strain, sugar, sample_no, self, rdf_graph)
              sample_no = sample_no + 1
            end
          end
        end
        rdf_graph
      end

      def sample_to_triple strain, sugar, sample_no, data_file, rdf_graph
        # TODO remove hardcoded uris
        sample_uri = RDF::URI.new("http://www.synthsys.ed.ac.uk/ontology/seek/sample/DF#{self.id}_#{sample_no}")
        strain_uri = RDF::URI.new("http://www.synthsys.ed.ac.uk/ontology/seek/peterSwain/strain/#{strain}")
        sugar_uri = RDF::URI.new("http://www.synthsys.ed.ac.uk/ontology/seek/peterSwain/sugar/#{sugar}")
        associated_with = RDF::URI.new("http://www.synthsys.ed.ac.uk/ontology/seek/centreOntology#associatedWith")
        contains = RDF::URI.new("http://www.synthsys.ed.ac.uk/ontology/seek/centreOntology#contains")
        derived_from = RDF::URI.new("http://www.synthsys.ed.ac.uk/ontology/seek/centreOntology#derivedFrom")
        data_file_uri = data_file.rdf_resource

        unless strain.nil? && sugar.nil?
          # Data file associated with sample
          rdf_graph << [data_file_uri, associated_with, sample_uri]

          # Sample contains sugar
          unless sugar.nil?
            rdf_graph << [sample_uri, contains, sugar_uri]
          end

          # Sample derived from strain
          unless strain.nil?
            rdf_graph << [sample_uri, derived_from, strain_uri]
          end
        end
      end

      def describe_type rdf_graph
       it_is = JERMVocab.for_type self
       unless it_is.nil?
         resource = self.rdf_resource
         rdf_graph <<  [resource,RDF.type,it_is]
       end
       rdf_graph
      end

      #the hash of namespace prefixes to pass to the RDF::Writer when generating the RDF
      def ns_prefixes
        {
            "jerm"=>JERMVocab.to_uri.to_s,
            "dcterms"=>RDF::DC.to_uri.to_s,
            "owl"=>RDF::OWL.to_uri.to_s,
            "foaf"=>RDF::FOAF.to_uri.to_s,
            "sioc"=>RDF::SIOC.to_uri.to_s,
            "owl"=>RDF::OWL.to_uri.to_s,
        }
      end

      def create_rdf_generation_job force=false,refresh_dependents=true
        unless !force && (self.changed - ["updated_at","last_used_at"]).empty?
          RdfGenerationJob.new(self,refresh_dependents).queue_job
        end
      end

      def remove_rdf
        self.remove_rdf_from_repository if self.rdf_repository_configured?
        self.delete_rdf_file
        refresh_dependents_rdf
      end

      def refresh_dependents_rdf
        dependent_items.each do |item|
          item.refresh_rdf if item.respond_to?(:refresh_rdf)
        end
      end

      def dependent_items
        items = []
        #FIXME: this should go into a seperate mixin for active-record
        methods=[:data_files,:sops,:models,:publications,
                 :data_file_masters, :sop_masters, :model_masters,
                 :assets,
                 :assays, :studies, :investigations,
                 :institutions, :creators, :owners,:owner, :contributors, :contributor,:projects, :events, :presentations,
                 :samples, :specimens, :compounds, :organisms, :strains,
                ]
        methods.each do |method|
          if self.respond_to?(method)
            deps = Array(self.send(method))
            #resolve User back to Person
            deps = deps.collect{|dep| dep.is_a?(User) ? [dep, dep.person] : dep }.flatten.compact
            items = items | deps
          end
        end

        items.compact.uniq

        if (self.rdf_repository_configured?)
          items = items | related_items_from_sparql
        end

        items.compact.uniq
      end

      def refresh_rdf
        create_rdf_generation_job(true, false)
      end

    end
  end
end
