class Topic < ActiveRecord::Base
  attr_accessible :name, :published, :slug
  #after_initialize :gen_slug
  before_create :ensure_uniq
  after_create :async_update

  scope :published,where(:published=>true)
  scope :recent,order("id asc")
  @queue = 'topic'
  include ResqueEx
  def to_param
    slug
  end
  def gen_slug
    return unless slug.nil?
    self[:slug] = Pinyin.t(name,'')
    if slug.length > 12
      self[:slug] = Pinyin.t(name).split(' ').collect{|str| str[0,1]}.join()
    end
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
  end
end
