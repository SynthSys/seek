class CreateDsPacks < ActiveRecord::Migration
  def change
    create_table :ds_packs do |t|
      t.string :title
      t.text :description
      t.integer :status
      t.text :msg
      t.references :assay

      t.timestamps
    end
    add_index :ds_packs, :assay_id
  end
end
