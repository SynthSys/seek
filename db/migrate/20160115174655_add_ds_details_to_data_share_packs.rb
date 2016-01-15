class AddDsDetailsToDataSharePacks < ActiveRecord::Migration
  def change
    change_column :data_share_packs, :snapshot_id, :integer, :null => false
    change_column :data_share_packs, :status, :integer, :null => false
    change_column :data_share_packs, :title, :string, :null => false
    change_column :data_share_packs, :description, :text, :null => false
    add_column :data_share_packs, :collection, :string, :null => false
    add_column :data_share_packs, :funder, :string, :null => false
    add_column :data_share_packs, :depositor, :string, :null => false
    add_column :data_share_packs, :publisher, :string, :null => false
    add_column :data_share_packs, :settype, :string, :null => false
    add_column :data_share_packs, :license, :string, :null => false
    add_column :data_share_packs, :creators, :string
    add_column :data_share_packs, :keywords, :string
    add_column :data_share_packs, :subject, :string
    add_column :data_share_packs, :toc, :text
    add_column :data_share_packs, :referenced_by, :string
    add_column :data_share_packs, :version_of, :string
    add_column :data_share_packs, :supersedes, :string
    add_column :data_share_packs, :source, :string
    add_column :data_share_packs, :embargo, :date
  end
end
