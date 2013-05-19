class Topic < ActiveRecord::Base
  attr_accessible :name, :published, :slug
  #after_initialize :gen_slug
  before_save :ensure_uniq
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
  def update!
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
    def import_all
      while r = self.where(:published=>nil).first and r.present?
        r.update!
      end
    end
  end
end
