class CreateEntryTexts < ActiveRecord::Migration
  def change
    create_table :entry_texts do |t|
      t.text :body
      t.references :entry
    end
    add_index :entry_texts, :entry_id
  end
end
