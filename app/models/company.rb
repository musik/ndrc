#encoding: utf-8
class Company < ActiveRecord::Base
    include CityHelper::ViewHelper
  attr_accessible :ali_url, :fuwu, :hangye, :location, :name , :text_attributes , :metas_attributes,:province_id,:city_id,:district_id
  has_one :text , :dependent => :destroy , :class_name => "CompanyText"
  has_many :metas , :dependent => :destroy , :class_name => "CompanyMeta"
  accepts_nested_attributes_for :text,:metas

  has_many :entries

  scope :recent,order("id desc")

  def to_params
    ali_url
  end
  define_index do
    indexes :name,:fuwu,:hangye,:location
    indexes text(:body),:as=>:description
    has :id
    #set_property :delta => ThinkingSphinx::Deltas::ResqueDelta
    set_property :delta => :datetime, :threshold => 75.minutes
  end
  sphinx_scope :any do
    {:match_mode=>:any}
  end
  def tagwords
    [hangye,fuwu].compact.join(";").split(';').uniq
  end
  def cats
    arr = hangye.split(';').compact.uniq
    cats = Category.where(:name=>arr)
    cats
  end
  def locs
    return @locs if @locs
    @locs = location.nil? ? nil :
      location.sub(/\[已认证\]/,'').split(/[ \/]/).compact.collect{|str|
        slug = Pinyin.t(str,'')
        logger.debug slug
        is_city_or_state?(slug) ? [str,slug] : nil
      }.compact.uniq
  end
  def detect_locations
    return if location.nil?
    pid = _detect_id(location,Province.cached_all)
    return nil if pid.nil?
    data = {province_id: pid}
    cid = _detect_id(location,City.where(province_id: pid).all)
    data[:city_id] = cid unless cid.nil?
    update_attributes data
  end
  async_method :detect_locations
  def _detect_id str,results
    hash = Hash[results.collect{|r| [r.id,r.short_name]}]
    patts = Regexp.new(hash.values.join('|'))
    match = str.match(patts)
    return nil if match.nil?
    hash.key(match.to_s)
  end
  
  class << self
    def detect_all_locations
      find_each do |r|
        r.detect_locations
      end
    end
    def fuwus
      arr = Company.pluck(:fuwu)
      arr += Company.pluck(:hangye)
      arr = arr.join(";").gsub(/[·． \\]/,'').gsub(/[，、]/,';').split(";")
      puts arr.size
      puts arr.uniq.size
      #arru = arr.uniq.reject{|r| r.bytesize > 27}
      File.open("#{Rails.root}/tmp/fuwus.csv","w") do |f|
        arr1 = arr.uniq.collect{|str|
          #[str,arr.count(str)]
          f.write "#{str},#{arr.count(str)}\n"
        }
        #arr1.sort!{|a,b| b[1] <=> a[1]}
        #Hash[arr1].each do |k,v|
          #f.write "#{k},#{v}\n"
        #end
      end
      nil
    end
    def parse_ali_url url
      url.match(/\/\/([\w\d]+?)\./)[1]
    end
    def import_data data
      e = where(:ali_url=>data[:ali_url]).first      
      if e.nil?
        metas = []
        data[:meta].each do |k,v|
          metas << {:mkey=>k,:mval=>v}
        end
        data[:metas_attributes] = metas
        meta = data.delete :meta

        {
          :fuwu => "主营产品或服务",
          :hangye => "主营行业",
          :location => "公司注册地",
        }.each do |k,v|
          data[k] = meta.delete v if meta.has_key? v
        end
        data[:text_attributes] = {:body=>data.delete(:desc)}
        create data
      else
        e
      end
    end
  end
end
