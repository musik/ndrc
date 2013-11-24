class AddImportedToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :imported_at, :datetime
  end
end
