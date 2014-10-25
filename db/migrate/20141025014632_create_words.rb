class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :name
      t.string :url

      t.timestamps
    end
    #add_index :words,:name,unique: true
    add_index :words,:url,unique: true
  end
end
