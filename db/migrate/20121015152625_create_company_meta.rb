class CreateCompanyMeta < ActiveRecord::Migration
  def change
    create_table :company_meta do |t|
      t.string :mkey
      t.string :mval
      t.references :company
    end
    add_index :company_meta, [:company_id,:mkey],:name=>"cmeta"
  end
end
