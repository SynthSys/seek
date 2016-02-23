
module Synthsys
  module Dspace

    class DspaceUploaderConnector

      class Config < Struct.new(:uri,:deposits_dir); end

      class DepositError < RuntimeError; end

      @@INSTANCE = nil

      def self.INSTANCE
        if @@INSTANCE == nil
          @@INSTANCE = DspaceUploaderConnector.new
        end
        return @@INSTANCE
      end

      def initialize(poster=nil,config=nil)
        if poster == nil
          @poster = Synthsys::Dspace::Poster.new
        else
          @poster = poster
        end

        if config == nil
          @config = read_configuration
          @alreadyConfigured = true
        else
          verify_config(config)
          @config = config
          @alreadyConfigured = true
        end

      end

      def url
        return @config.uri
      end

      def deposit(dataSharePack)
        read_configuration unless @alreadyConfigured


        depositFile = prepareDataPackage(dataSharePack)
        begin
          deposit = prepare_deposit(dataSharePack,depositFile)

          @poster.post(@config.uri,deposit.to_json)
        ensure
          depositFile.close
          depositFile.unlink
        end
      end


=begin
      def do_deposition(poster,uri,deposit_string)
        response = poster.post(uri,deposit_string)

        case response
          when Net::HTTPSuccess then
            return true
          when Net::HTTPResponse then
            msg = 'Deposit failed'
            if response.class.body_permitted?
              msg = "Deposit failed:\n #{response.body}"
            end
            raise DepositError.new msg
          else
            msg = "Deposit failed, unknown response #{response}"
            raise DepositError.new msg
        end

      end
=end


      def prepare_deposit(dataSharePack,depositFile)

        deposit = {
            collection: dataSharePack.collection,

            title: dataSharePack.title,
            description: dataSharePack.description,
            funder: dataSharePack.funder,
            depositor: dataSharePack.depositor,
            publisher: dataSharePack.publisher,
            creators: dataSharePack.creators,
            keywords: dataSharePack.keywords,
            subject: dataSharePack.subject,
            toc: dataSharePack.toc,
            licence: dataSharePack.license,
            type: "Dataset"
        }

        deposit[:filePath] = File.basename(depositFile)
        deposit[:fileType] = 'application/zip'
        deposit[:fileName] = makeDepositFileName(dataSharePack)
        return deposit

        #TODO deal with source link and dates
        #public String source;
        #public String createdAtStr;
        #public String updatedAtStr;



      end

      def prepareDataPackage(dataSharePack,deposits_dir = @config.deposits_dir)
        content = dataSharePack.snapshot.content_blob
        if content == nil
          raise Exception.new "No content blob in snapshot: #{dataSharePack.snapshot.id}"
        end
        path = content.filepath
        if !File.file?(path)
          raise Exception.new "Content file #{path} does not exists for snapshot: #{dataSharePack.snapshot.id}"
        end
        #return path
        return makeDepositCopy(path,deposits_dir)
      end

      def makeDepositCopy(path,deposits_dir)

         depositFile = Tempfile.new(File.basename(path), deposits_dir)
         FileUtils.copy(path,depositFile.path)
         return depositFile

      end

      def makeDepositFileName(dataSharePack)
        parent = dataSharePack.snapshot.resource
        return "#{parent.class}.#{parent.id}.ro.zip"
      end

      def read_configuration
        if configured?
          y = YAML.load_file(config_path)
          @config=Config.new
          @config.uri=y[Rails.env]["uri"]
          @config.deposits_dir=y[Rails.env]["deposits_dir"]
          #@config = Config.new
          #@config.uri = 'http://localhost:8550/deposit'
          verify_config(@config)
          @alreadyConfigured = true
          return @config
        else
          raise Exception.new "No configuration file found"
        end
      end

      def verify_config(configuration)
        if !File.directory?(configuration.deposits_dir)
          raise "#{configuration.deposits_dir} does not point to a valid dir"
        end
        if !File.writable?(configuration.deposits_dir)
          raise "Cannot write to deposits dir: #{configuration.deposits_dir}"
        end

      end

      def configured?
        File.exists?(config_path) && enabled_for_environment?
        #true
      end

      def config_path
        File.join(Rails.root,"config","dspace.yml")
      end

      def enabled_for_environment?
        y = YAML.load_file(config_path)
        !y[Rails.env].nil? && !y[Rails.env]["disabled"]
      end
    end
  end

end
