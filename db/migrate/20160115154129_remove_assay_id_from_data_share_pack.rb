class RemoveAssayIdFromDataSharePack < ActiveRecord::Migration
  def up
    remove_column :data_share_packs, :assay_id
  end

  def down
    add_column :data_share_packs, :assay_id, :integer
  end
end
