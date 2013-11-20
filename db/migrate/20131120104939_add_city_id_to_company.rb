class AddCityIdToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :district_id, :integer
    add_column :companies, :city_id, :integer
    add_column :companies, :province_id, :integer
  end
end
