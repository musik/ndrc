class AddCompaniesCountToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :companies_count, :integer
  end
end
