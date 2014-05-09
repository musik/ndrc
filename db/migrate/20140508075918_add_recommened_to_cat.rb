class AddRecommenedToCat < ActiveRecord::Migration
  def change
    add_column :cats, :recommended, :string
  end
end
