class DsPack < ActiveRecord::Base
  belongs_to :assay
  #attr_accessible :description, :msg, :status, :title

  validates :title,  presence: true, length: { maximum: 140, minimum: 10 }
  validates :description,  presence: true
  validates :assay_id, presence: true
  validates :assay, presence: true

end
