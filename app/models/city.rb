# -*- encoding: utf-8 -*-
class City < ActiveRecord::Base
  attr_accessible :name, :province_id, :level, :zip_code, :pinyin, :pinyin_abbr
  
  belongs_to :province
  has_many :districts, dependent: :destroy

  def short_name
    @short_name ||= name.gsub(/市|自治州|地区|特别行政区/,'')
  end

  def brothers
    @brothers ||= City.where("province_id = #{province_id}")
  end
  class << self
    def url str
      str.to_url.gsub("-",'')
    end
    def locations_from_str str
      arr = str.split(/[ \/]/).compact.uniq
      if arr.present?
        city = City.where(:name=>arr).first
      end
    end
  end

end
