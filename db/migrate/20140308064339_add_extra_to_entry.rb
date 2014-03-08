class AddExtraToEntry < ActiveRecord::Migration
  def change
    remove_index :entries,:ali_id
    rename_column :entries,:ali_id, :ali_url
    change_column :entries,:ali_url, :string
    add_index :entries, :ali_url
    add_column :entries, :kind, :integer
    add_column :entries, :keywords, :string
    add_column :entries, :photo, :string
    add_column :entries, :hangye, :string
    add_column :entries, :pinpai, :string
    add_column :entries, :district_id, :integer
    add_column :entries, :city_id, :integer
    add_column :entries, :province_id, :integer

  end
end
