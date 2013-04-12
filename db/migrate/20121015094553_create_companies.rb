class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :fuwu
      t.string :hangye
      t.string :location
      t.string :ali_url

      t.timestamps
    end
    add_index :companies,:ali_url,:uniq=>true
  end
end
