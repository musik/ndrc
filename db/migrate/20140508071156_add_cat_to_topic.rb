class AddCatToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :cat_id, :integer
    add_column :topics, :priority, :integer
    add_column :topics, :level, :integer
  end
end
