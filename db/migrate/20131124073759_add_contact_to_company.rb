class AddContactToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :contact, :string,:limit=>18
    add_column :companies, :address, :string,:limit=>120
    add_column :companies, :phone, :string,:limit=>30
    add_column :companies, :mobile, :string,:limit=>30
  end
end
