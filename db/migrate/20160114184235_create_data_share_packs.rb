class CreateDataSharePacks < ActiveRecord::Migration
  def change
    create_table :data_share_packs do |t|
      t.string :title
      t.text :description
      t.integer :status
      t.text :msg
      t.references :assay

      t.timestamps
    end
    add_index :data_share_packs, :assay_id
  end
end
