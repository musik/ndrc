class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name
      t.string :slug
      t.boolean :published

      t.timestamps
    end
    add_index :topics,:name,:uniq=>true
    add_index :topics,:slug,:uniq=>true
  end
end
