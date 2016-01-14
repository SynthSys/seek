class DsPack < ActiveRecord::Base
  belongs_to :assay
  attr_accessible :description, :msg, :status, :title

  validates :title,  presence: true
  validates :description,  presence: true

end
