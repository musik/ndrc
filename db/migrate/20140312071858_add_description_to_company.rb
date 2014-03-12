class AddDescriptionToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :description, :string
    add_column :entries, :description, :string
  end
end
