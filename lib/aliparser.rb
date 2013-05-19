module Aliparser
    REG_CAT_URL = /http:\/\/search\.china\.alibaba\.com\/selloffer\/--(\d+).html/
    REG_LIST_URL = /http:\/\/search\.china\.alibaba\.com\/company\/-([\w\d]+)\.html/
    REG_COM_URL = /http:\/\/([a-z0-9\-]).cn.alibaba.com/
    REG_INFO_URL = /http:\/\/detail.china.alibaba.com\/offer\/(\d+).html/
  def cats_links page_links
    links = []
    page_links.each do |link|
      links << to_cat_url(link.to_s)
    end
    links.compact.uniq
  end
  def import_cats page 
   return if page.url.to_s.match(REG_CAT_URL).nil?
   @catsdb ||= db("cats")
   @catsdb[page.url.to_s] = true
   cs = []
   page.doc.css('#sw_mod_navigatebar > ul li a').each do |link|
     ms = link.attr('href').match(REG_CAT_URL)
     next if ms.nil?
     cid = ms[1]
     cs << [link.text.strip,cid]
   end
    Category.import_breads cs
  end
  def db(name)
    Mykt.new("db/#{name}-#{Rails.env}.kch")
  end
  def find_more_cats page
    @catsdb ||= db("cats")
    links = cats_links page.ali_links
    links.each do |str|
      next if @catsdb.has_key? str
      @catsdb[str]=nil
      Category.delay.import_by_url str,true
    end
  end
  def find_more_list page
    @redis ||= Redis::Namespace.new("resque:ali",:redis=>Resque.redis.redis)
    links = parse_list_links page.ali_links
    key = "list"
    links.each do |str|
      val = str.match(/\-([\w\d]+)\.html/)[1]
      next if @redis.sismember key,val
      @redis.sadd key,val 
      Resque.enqueue(List,val)
    end
  end
  def find_more_infos page
    links = parse_info_links page.ali_links
    pp links
  end
  def parse_info_links page_links
    links = []
    page_links.each do |link|
      links << to_info_id(link)
    end
    links.compact.uniq
  end
  def find_more_coms page
    @redis ||= Redis::Namespace.new("resque:ali",:redis=>Resque.redis.redis)
    links = parse_companies_links page.ali_links
    #logm links
    key = "com"
    links.each do |str|
      val = str.match(/\/\/([\w\d]+?)\./)[1]
      next if @redis.sismember key,val
      @redis.sadd key,val 
      Resque.enqueue(Comque,val)
    end
  end
  def parse_companies_links page_links
    links = []
    page_links.each do |link|
      links << to_company_url(link)
    end
    links.compact.uniq
  end
  def to_cat_url link
    link.to_s.match(/^http:\/\/search\.china\.alibaba\.com\/selloffer\/\-\-[0-9]+\.html/)[0] rescue nil
  end
  def parse_com_page page 
  end
  def parse_list_links page_links
    links = []
    page_links.each do |link|
      links << to_list_url(link.to_s)
    end
    links.compact.uniq
  end
  def to_info_id link
    link.to_s.match(REG_INFO_URL)[1].to_i rescue nil
  end
  def to_company_url link
    link.to_s.match(/^http:\/\/([a-z\d\-]+)\.cn\.alibaba\.com/)[0] rescue nil
  end
  def to_list_url link
    link.to_s.match(REG_LIST_URL)[0] rescue nil
  end
  def url_like? pattern,str
    str.match(pattern).present?
  end
  class Cat 
    @queue = :com_by_cat
    def self.perform cid
      Ali::Robot.new.parse_coms_from_cat cid
    end
  end      
  class List 
    @queue = :com_list
    def self.perform url
      Ali::Robot.new.parse_list url
    end
  end      
  class Comque 
    @queue = :company
    def self.perform url
      res = Ali::Robot.new.parse_company(url)
      if res == false
        @redis ||= Redis::Namespace.new("resque:ali",:redis=>Resque.redis.redis)
        @redis.sadd "com_failed",url
      end
    end
  end      


end
