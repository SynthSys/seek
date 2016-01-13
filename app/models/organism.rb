

class Organism < ActiveRecord::Base
  include Seek::Rdf::RdfGeneration

  acts_as_favouritable

  linked_to_bioportal :apikey=>Seek::Config.bioportal_api_key
  
  has_many :assay_organisms
  has_many :models
  has_many :assays,:through=>:assay_organisms  
  has_many :strains, :dependent=>:destroy
  has_many :specimens, :through=>:strains

  has_and_belongs_to_many :projects

  validates_presence_of :title

  def can_delete? user=User.current_user
    !user.nil? && user.is_admin_or_project_administrator? && models.empty? && assays.empty? && projects.empty?
  end

  def searchable_terms
    terms = [title]
    if concept
      terms = terms | concept[:synonyms].collect{|s| s.gsub("\"","")} if concept[:synonyms]
      terms = terms | concept[:definitions].collect{|s| s.gsub("\"","")} if concept[:definitions]
    end
    terms
  end

  def self.can_create?
    User.admin_or_project_administrator_logged_in? || User.activated_programme_administrator_logged_in?
  end

end
