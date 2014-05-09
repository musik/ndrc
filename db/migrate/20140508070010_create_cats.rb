class CreateCats < ActiveRecord::Migration
  def change
    create_table :cats do |t|
      t.string :name
      t.string :slug
      t.integer :priority

      t.timestamps
    end
  end
end
