#encoding: utf-8
class Topic < ActiveRecord::Base
  paginates_per 100
  attr_accessible :name, :published, :slug,:companies_count,:abbr,
    :priority,:level,:cat_id
  validates_presence_of :name
  #after_initialize :gen_slug
  #after_save :import_companies_when_publish
  after_create :import_companies
  before_create :ensure_uniq
  belongs_to :cat

  scope :published,where(:published=>true)
  scope :recent,order("id desc")
  @queue = 'topic'
  #include ResqueEx
  define_index do
    indexes :name
    has :id
    where sanitize_sql(["published", true])
    set_property :delta => :datetime, :threshold => 75.minutes
  end
  def to_param
    slug
  end
  def gen_slug
    self.slug = name.to_url.gsub(/-/,'')[0,16]
  end
  def ensure_uniq
    gen_slug
    base_str = slug
    current_slug = base_str
    i = 1
    while Topic.exists?(slug: current_slug)
      current_slug = base_str + '-' + i.to_s
      i+=1
    end
    self[:slug] = current_slug
    str = current_slug[0,1]
    str = "0" unless str.to_i.zero? 
    self[:abbr] = str
    self
  end
  def ali_url
    sprintf 'http://search.china.alibaba.com/selloffer/-%s.html',CGI.escape(name.encode('GBK','UTF-8')).gsub('%','')
  end
  def import_companies_when_publish
    import_companies if changes.key?("published") && changes["published"][1] == true
  end
  def import_companies
    return if Rails.env.test?
    Company.ali_search name
    update_attribute :imported_at,Time.now
  end
  async_method :import_companies
  class << self
    def db_init
      HyRobot::Core.new.run_topics
    end
    def import_from_str str,publish=true
      str.gsub(/[·． \\” “"。]/,'').gsub(/[，、,；]/,';').split(";").uniq.compact.each do |s|
        s.strip!
        next if s.blank?
        next if s.count(".") > 1
        next if s.bytesize > 30
        next if %(* ： . \ / ! @ ？ ? # $ % ^ & ( )  】 ] ） ×).include?(s[-1])
        next if s.match(/^[0-9\.\#\%]+$/).present?
        next if s.match(/^各类|各种|其他|其它/).present?
        Topic.find_by_name(s) || Topic.create(name: s,published: publish)
      end
    end
    def dump_to_csv
      File.open("#{Rails.root}/db/topics_dump.csv",'w') do |f|
        Topic.where('length(name) < 22').order('char_length(name) asc').find_each do |t|
          f.write(t.name + "\r\n")
        end
      end
      nil
    end
    def filter_dump_csv_pe
      cats = File.readlines("#{Rails.root}/public/pecats.txt")
      pattern = Regexp.new( cats.join("|").gsub(/[\r\n]/,''),Regexp::IGNORECASE)
      f1 = File.open("#{Rails.root}/db/petopics.txt",'w')
      Topic.order('char_length(name) asc').find_each do |t|
        f1.write(t.name + "\r\n") if t.name.match(pattern).present?
      end
      nil

    end
    def filter_dump_csv
      cats = File.readlines("#{Rails.root}/public/yscats.txt")
      pattern = Regexp.new( cats.join("|").encode('UTF-8','GBK').gsub(/\r\n/,''),Regexp::IGNORECASE)
      f1 = File.open("#{Rails.root}/db/topics1.txt",'w')
      f2 = File.open("#{Rails.root}/db/topics2.txt",'w')
      Topic.order('char_length(name) asc').find_each do |t|
        t.name.match(pattern).present? ?
          f1.write(t.name + "\r\n") :
          f2.write(t.name + "\r\n")
      end
      nil

    end
    def import_from_csv
      file = "#{Rails.root}/db/topics.csv"
      File.read(file).split("\n").collect{|r| r.split(",")}.each do |arr|
        where(:name=>arr[0]).first_or_create :companies_count=>arr[1],:published=>true
      end
    end
    def fix_slugs
      find_each do |r|
        (r.destroy and next) if r.name.match(/^[0-9\.\#]+$/).present?
        (r.destroy and next) if r.slug.match(/^[0-9\.\#]+$/).present?
        next if r.slug.match(/^[[a-z][0-9]-]+$/i).present?
        (r.destroy and next) if %(* . \ / ! @ # $ % ^ & ( ) ×).include?(r.name[-1])
        (r.destroy and next) if r.name.empty?
        r.update_attribute :slug,r.gen_slug
      end
      nil
    end
    def test_alizhishu
      get_cat 70
    end
    def get_cat cat
      %w(rise hot new word).product(%w(week month)).each do |arr|
        get_words cat,arr[0],arr[1]
      end
    end
    def get_words cat,type,period
      url = "http://index.1688.com/alizs/word/listRankType.json?cat=#{cat}&rankType=#{type}&period=#{period}"
      pp url
      #page = Anemone::HTTP.new.fetch_page(url)
    end
  end
end
