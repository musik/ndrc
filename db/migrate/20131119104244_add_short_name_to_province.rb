#encoding: 
class AddShortNameToProvince < ActiveRecord::Migration
  def change
    add_column :provinces,:short_name,:string,:limit=>9
    Province.all.each do |p|
      short = p.name[0,2]
      short = p.name[0,3] if %w(内蒙 黑龙).include?(short)
      p.update_attribute :short_name,short
    end
  end
end
