class AddIndexToDataSharePack < ActiveRecord::Migration
  def change
    add_index :data_share_packs, :snapshot_id
  end
end
