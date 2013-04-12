class AddDeltaToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :delta, :boolean, :default => true,:null => false
    add_index :companies, :delta
  end
end
