module HyRobot
  def self.run
    core = Core.new
    core.run
  end
  class Core
    REG_CAT_URL = /http:\/\/search\.china\.alibaba\.com\/selloffer\/--(\d+).html/
    REG_LIST_URL = /http:\/\/search\.china\.alibaba\.com\/company\/-([\w\d]+)\.html/
    REG_COM_URL = /http:\/\/([a-z0-9\-]).cn.alibaba.com/
    def run homepage=nil
      homepage ||= 'http://page.china.alibaba.com/cp/cp1.html'
      #homepage ||= 'http://page.china.alibaba.com/buy/index.html'
      #homepage ||= 'http://search.china.alibaba.com/selloffer/--14.html'
      depth = 0
      Anemone.crawl(homepage,:depth_limit=>depth,:user_agent=>"Soso",:verbose=>true) do |anemone|
        #anemone.storage = Anemone::Storage.KyotoCabinet('companies.kch')
        anemone.storage = Anemone::Storage.Redis
        anemone.on_every_page{|page|
          page.conv('GB2312')
          page.ali_links
        }.focus_crawl { |page|
          companies_links = parse_companies_links page.links
          list_links = parse_list_links(page.links - companies_links)
          logm companies_links + list_links
          companies_links + list_links
        }.on_pages_like(REG_COM_URL){|page|
          parse_com_page page
        }
      end
    end
    def run_cats homepage=nil
      homepage ||= 'http://page.china.alibaba.com/buy/index.html'
      depth = 5
      Anemone.crawl(homepage,:depth_limit=>depth,:user_agent=>"Soso",:verbose=>true) do |anemone|
        anemone.storage = Anemone::Storage.KyotoCabinet('cats.kch')
        anemone.on_every_page{|page|
          page.conv('GB2312')
          page.ali_links
        }.focus_crawl { |page|
           parse_cats_links(page.links)
        }.on_pages_like(REG_CAT_URL){|page|
          parse_cat_page page
        }
      end
    end
    def recheck_pages
      #kc = Anemone::Storage.KyotoCabinet
      #puts kc.keys
      require 'kyotocabinet'
      #include KyotoCabinet

      db = KyotoCabinet::DB::new()
      db.open('anemone.kch')
      us = []
      db.each{|key,val|
        cid = key.scan(/\d+/)
        us << key unless  Category.find_by_cid(cid).present?
      }
      puts us.size
      puts us.uniq.size

    end
    def fetch_cat url
      page = Anemone::HTTP.new.fetch_page url
      parse_cat_page page
    end
    def parse_cat_page page 
     cs = []
     page.doc.css('#sw_mod_navigatebar > ul li a').each do |link|
       ms = link.attr('href').match(REG_CAT_URL)
       next if ms.nil?
       cid = ms[1]
       cs << [link.text.strip,cid]
     end
      Category.import_breads cs
    end
    def parse_com_page page 
    end
    def parse_cats_links page_links
      links = []
      page_links.each do |link|
        links << to_cat_url(link.to_s)
      end
      links.compact.uniq.map{|str| URI(str)}
    end
    def parse_list_links page_links
      links = []
      page_links.each do |link|
        links << to_list_url(link.to_s)
      end
      links.compact.uniq.map{|str| URI(str)}
    end
    def parse_companies_links page_links
      links = []
      page_links.each do |link|
        links << to_company_url(link)
      end
      links.compact.uniq.map{|str| URI(str + "/")}
    end
    def to_company_url link
      link.to_s.match(/^http:\/\/([a-z\d\-]+)\.cn\.alibaba\.com/)[0] rescue nil
    end
    def to_cat_url link
      link.to_s.match(/^http:\/\/search\.china\.alibaba\.com\/selloffer\/\-\-[0-9]+\.html/)[0] rescue nil
    end
    def to_list_url link
      link.to_s.match(REG_LIST_URL)[0] rescue nil
    end
    def is_company? link
      return false unless link.present?
      link.to_s.match(/^http:\/\/([\w\d\-\_]+).cn.alibaba.com/).present?
    end
    def chosen? link
      logm link
    end
  end
end  
