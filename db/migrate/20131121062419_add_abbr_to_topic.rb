class AddAbbrToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :abbr, :string,:limit=>1
    add_index :topics,:abbr
  end
end
