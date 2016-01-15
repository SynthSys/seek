class AddSnapshotRefToDataSharePack < ActiveRecord::Migration
  def change
    add_column :data_share_packs, :snapshot_id, :integer

  end
end
