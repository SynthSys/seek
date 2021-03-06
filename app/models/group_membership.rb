class GroupMembership < ActiveRecord::Base
  belongs_to :person
  belongs_to :work_group
  has_one :project, :through=>:work_group

  has_many :group_memberships_project_positions, :dependent => :destroy
  has_many :project_positions, :through => :group_memberships_project_positions

  after_save :remember_previous_person
  after_update { remove_admin_defined_role_projects if has_left }
  after_commit :queue_update_auth_table
  after_destroy :remove_admin_defined_role_projects

  validates :work_group,:presence => {:message=>"A workgroup is required"}

  def has_left=(yes = false)
    self.time_left_at = yes ? Time.now : nil
  end

  def has_left
    self.time_left_at && self.time_left_at.past?
  end

  def remember_previous_person
    @previous_person_id = person_id_was
  end

  def queue_update_auth_table
    people = [Person.find_by_id(person_id)]
    people << Person.find_by_id(@previous_person_id) unless @previous_person_id.blank?

    AuthLookupUpdateJob.new.add_items_to_queue people.compact
  end

  #whether the person can remove this person from the project. If they are an administrator and related programme administrator they can, but otherwise they cannot remove themself.
  #this is to prevent a project admin accidently removing themself and leaving the project un-administered
  def person_can_be_removed?
    !person.me? || User.current_user.is_admin? || person.is_programme_administrator?(project.programme)
  end

  private

  def remove_admin_defined_role_projects
    project = Project.find_by_id(WorkGroup.find(work_group_id_was).project_id)
    person = Person.find_by_id(person_id_was)
    if project && person
      Seek::Roles::ProjectRelatedRoles.role_names.each do |role_name|
        person.send("is_#{role_name}=", [false, project])
      end
      disable_authorization_checks { person.save }
    end
  end

end
