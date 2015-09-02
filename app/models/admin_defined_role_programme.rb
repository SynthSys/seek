class AdminDefinedRoleProgramme < ActiveRecord::Base
  belongs_to :programme
  belongs_to :person

  #a less specific name for the associated item, that allows for more general methods in its usage
  alias_method :item,:programme

  after_commit :queue_update_auth_table, :if=>:persisted?
  before_destroy :queue_update_auth_table

  validates :programme,:person, presence:true
  validates :role_mask,numericality: {greater_than:0,less_than_or_equal_to:32}

  private

  def queue_update_auth_table
    AuthLookupUpdateJob.new.add_items_to_queue person
  end

end
