class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :title
      t.decimal :price,:precision=>10,:scale=>2
      t.integer :ali_id
      t.references :company
      t.string :location_name

      t.timestamps
    end
    add_index :entries, :company_id
    add_index :entries, :ali_id,:uniq=>true

    add_column :companies,:entries_count,:integer,:default=>0
  end
end
