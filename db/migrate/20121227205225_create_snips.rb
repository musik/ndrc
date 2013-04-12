class CreateSnips < ActiveRecord::Migration
  def change
    create_table :snips do |t|
      t.string :name
      t.text :data
    end
    add_index :snips,:name
  end
end
