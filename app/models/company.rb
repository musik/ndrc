#encoding: utf-8
class Company < ActiveRecord::Base
    include CityHelper::ViewHelper
  attr_accessible :ali_url, :fuwu, :hangye, :location, :name , :text_attributes , :metas_attributes,:province_id,:city_id,:district_id,
    :contact,:address,:phone,:mobile, :companies_count,
    :short,:logo,:description
  validates_uniqueness_of :ali_url
  validates_presence_of :name
  has_one :text , :dependent => :destroy , :class_name => "CompanyText"
  has_many :metas , :dependent => :destroy , :class_name => "CompanyMeta"
  accepts_nested_attributes_for :text,:metas

  has_many :entries

  scope :recent,order("id desc")
  belongs_to :city
  belongs_to :province

  before_save :gen_description

  def gen_description
    return if self[:decription].present? or text.body.nil?
    self[:description] = ActionController::Base.helpers.strip_tags(text.body)
    self[:description].gsub!(/\n|\t|&nbsp;|\\n|\\t/,'')
    self[:description].gsub!(/\s/,'')
  end

  def to_params
    ali_url
  end
  def short_name
    return short if short.present?
    return @short if @short.present?
    @short = name.gsub(/有限责任公司|有限公司/,'')
    @short = @short.gsub(/厂|门市部$/,'')
    if(city.present?)
      @short.gsub!(/^#{city.name}|#{city.short_name}/,'')
    end
    @short.gsub!(/^..市/,'')
    @short
  end
  define_index do
    indexes :name,:fuwu,:hangye,:location,:address
    #indexes text(:body),:as=>:description
    indexes :description
    has :id
    has :province_id,:city_id,:facet=>true
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
    return if location.nil? && address.nil?
    str = address || location
    pid = _detect_id(str,Province.cached_all)
    return nil if pid.nil?
    data = {province_id: pid}
    cid = _detect_id(str,City.where(province_id: pid).all)
    data[:city_id] = cid unless cid.nil?
    update_attributes data
  end
  def auto_province
    return if location.nil? && address.nil?
    str = location || address
    pid = _detect_id(str,Province.cached_all)
    return nil if pid.nil?
    self.province_id = pid
    cid = _detect_id("#{location},#{address}",City.where(province_id: pid).all)
    self.city_id = cid unless cid.nil?
  end
  async_method :detect_locations
  def _detect_id str,results
    return nil if results.empty?
    hash = Hash[results.collect{|r| [r.id,r.short_name]}]
    patts = Regexp.new(hash.values.join('|'))
    match = str.match(patts)
    return nil if match.nil?
    hash.key(match.to_s)
  end
  def self.province_facets q
    @province_counts = Company.facets(q,facets: :province_id)[:province_id]
    @provinces = Province.where(id: @province_counts.keys)
    @provinces.collect! do |r|
      [r,@province_counts[r.id]]
    end
    Hash[@provinces.sort{|a,b| b[1] <=> a[1]}]
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
      arru = arr.uniq.reject{|r| r.bytesize > 27}
      puts arru.uniq.size
      arrn = []
      hash = Hash.new 0
      arr.each{|str|
        hash[str] += 1
      }
      hash.delete_if{|k,v| v < 3}
      puts hash.keys.size
      File.open("#{Rails.root}/tmp/fuwus_more_than_twice.csv","w") do |f|
        f.write hash.collect{|r| r.join(',')}.join("\n")
        #arr.uniq.each{|str|
          #f.write "#{str},#{arr.count(str)}\n"
        #}
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
    def ali_search q
      slugs = Bot1688::Company.search(q).slugs
      slugs.each do |s|
        next if where(ali_url: s).exists?
        import_data(Bot1688::Company.new(s).details)
      end
    end
    def import_data data
      return if data.nil?
      #return if where(ali_url: data[:ali_url]).exists?
      metas = data.delete :metas
      {fuwu: "主营产品或服务",hangye: "主营行业"}.each do |k,v|
        data[k] = metas.delete(v) if metas.has_key?(v)
      end
      metas_attributes = []
      metas.each do |k,v|
        metas_attributes << {:mkey=>k,:mval=>v}
      end
      data[:metas_attributes] = metas_attributes
      data[:text_attributes] = {:body=>data.delete(:desc)}
      e = new data
      e.auto_province
      e.save
      Topic.import_from_str [e.fuwu,e.hangye].join(";")
    end
  end
  def self.import_from_tz data
    ali_url = "sm" + data.delete('cpID')
    e = where(ali_url: ali_url).first
    return e if e.present?
    r = {ali_url: ali_url}
    attr_map = {
      fuwu: "cpMasterProduct",
      hangye: "B2BIndustryName",
      location: "B2BAreaNamePlace",
      phone: "cpTel",
      short: "cpShortName",
      contact: "cpMember"
    }
    attr_map.each do |k,v|
      r[k] = data.delete(v) if data.has_key?(v)
    end
    attribute_names.each do |k|
      tk = "cp" + k.camelize
      if data.has_key?(tk)
        r[k] = data.delete(tk)
      end
    end
    r[:text_attributes] = {:body=>data.delete("cpAbout")}
    meta_map = {
      'cpSite'=> "官方网站",
    }
    metas_attributes = []
    meta_map.each do |dk,k|
      metas_attributes << {:mkey=>k,:mval=>data.delete(dk)}  if data[dk].present?
    end
    r[:metas_attributes] = metas_attributes
    r = new(r)
    r.auto_province
    r
  end
  def self.fetch_from_tz_id tzid,subdomain
    return nil if subdomain.nil?
    if subdomain == 'zs'
      fetch_from_zs(tzid)
    end
  end
  def self.fetch_from_zs tzid
    ali_url = "sm#{tzid}"
    e = where(ali_url: ali_url).first
    return e if e.present?
    url = "http://tztz#{tzid}.zhaoshang100.com/gongsijianjie/"
    response = Typhoeus.get(url)
    if response.success?
      doc = Nokogiri::HTML(response.body)
      keys = %w(公司名称 公司地址 联系电话 公司主页 联系人)
      data = {ali_url: ali_url}
      data["text_attributes"] = {body: doc.css('#bodyright .left-border table')[0].text.strip}
      hash = {}
      doc.css('#bodyright .left-border table')[1].css('td').each do |node|
        str = node.text.strip.sub("：",'')
        next unless keys.include?(str)
        hash[str]= node.next().next().text.strip
      end
      {name: "公司名称",address: "公司地址",phone: "联系电话",
        contact: "联系人"}.each do |k,v|
        data[k] = hash[v]
        end
      data[:metas_attributes] = [{mkey: "官方网站",mval: hash["公司主页"]}] if hash["公司主页"].present?
      r= new(data)
      r.auto_province
      r.save
      r
    end
  end
  def self.update_all_description
    where(description: nil).includes(:text).find_each do |r|
      r.save
    end
  end
end
