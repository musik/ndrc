class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :slug
      t.integer :parent_id,:lft,:rgt,:depth

      t.integer :cid
    end
    add_index :categories,:slug,:uniq=>true
    add_index :categories,[:parent_id,:lft,:rgt],:name=>:plr
  end
end
