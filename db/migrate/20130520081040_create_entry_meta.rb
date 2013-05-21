class CreateEntryMeta < ActiveRecord::Migration
  def change
    create_table :entry_meta do |t|
      t.string :mkey
      t.string :mval
      t.references :entry
    end
    add_index :entry_meta, :entry_id
  end
end
