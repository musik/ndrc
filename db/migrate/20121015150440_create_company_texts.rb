class CreateCompanyTexts < ActiveRecord::Migration
  def change
    create_table :company_texts do |t|
      t.text :body
      t.references :company
    end
    add_index :company_texts, :company_id
  end
end
