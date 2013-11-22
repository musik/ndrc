#encoding: utf-8
class Topic < ActiveRecord::Base
  paginates_per 100
  attr_accessible :name, :published, :slug,:companies_count,:abbr
  validates_presence_of :name
  #after_initialize :gen_slug
  #after_create :async_update
  before_create :ensure_uniq

  scope :published,where(:published=>true)
  scope :recent,order("id asc")
  @queue = 'topic'
  include ResqueEx
  define_index do
    indexes :name
    has :id
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
    while Topic.where(:slug=>current_slug).exists?
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
  def async_update
    async 'update!'
  end
  def update!
    logm ali_url
    page = Anemone::HTTP.new.fetch_page ali_url
    if page.code == 200
      Ali::Robot.new.find_more_infos page
      HyRobot::Core.new.import_topics page.links
      @status = true
    end
    @status ||= false
    update_attribute :published,@status
  end
  class << self
    def db_init
      HyRobot::Core.new.run_topics
    end
    def import_all
      #while r = self.where(:published=>nil).first and r.present?
        #r.update!
      #end
      self.where(:published=>nil).select(:id).all.each do |r|
        r.async 'update!'
      end
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
  end
end
