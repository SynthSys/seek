class DataSharePack < ActiveRecord::Base
  belongs_to :snapshot
  attr_accessible :description, :title, :snapshot_id
  #attr_accessible :description, :msg, :status, :title, :assay_id

  validates :title,  presence: true, length: { maximum: 140, minimum: 10 }
  validates :description,  presence: true
  validates :snapshot_id, presence: true
  validates :snapshot, presence: true

  def parent
    snapshot.parent unless snapshot==nil
  end
end
