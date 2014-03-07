class AddExtrasToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :short, :string
    add_column :companies, :logo, :string
  end
end
