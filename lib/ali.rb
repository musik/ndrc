#encoding: utf-8
require 'anemone/page_ex'
require 'aliparser'
module Ali 
  def self.run
    Robot.new.run
  end
  class Robot
      include Aliparser
    def init_cats
      url = 'http://page.china.alibaba.com/buy/index.html'
      parse_cats url,true
    end
    def init_coms
      url = 'http://page.china.alibaba.com/cp/cp1.html'
      parse_list url,true
    end
  
    def http
      @http ||= Anemone::HTTP.new(:user_agent=>"Soso")
    end
    def parser
      @parser ||= Aliparser.new
    end
    def parse_info id
      url = "http://detail.china.alibaba.com/offer/#{id}.html"
      page = http.fetch_page url
      return false if page.code != 200
      doc = page.doc
      company_slug = doc.at_css('.logo a').attr('href').match(/\/\/(.+?)\.cn/)[1]
      company = parse_company company_slug
      if company.present?
        logm company
        data = {
          :title => doc.at_css('h1').text(),
        }
        prices = doc.css('#mod-detail-price tbody tr').collect do |tr|
          JSON.parse(tr.attr('data-range'))
        end
        data[:price] = prices.first["price"] if prices.present?

        features = doc.css('.de-feature').collect{|node| node.text()}
        data[:meta] = {
          :prices => prices,
          :features => features
        }

        logm data
      end
    end
    def parse_company ali_url
      homeurl = "http://#{ali_url}.cn.alibaba.com"
      url = "#{homeurl}/page/creditdetail.htm"
      page = http.fetch_page url
      return false if page.code != 200
      doc = page.doc
      data = {
        :ali_url => ali_url
      }
      meta = {}
      data[:name] = doc.at_css(".chinaname").text.strip rescue nil
      return false if data[:name].nil?
      doc.xpath("//td[@class='ta2']").each do |td|
        val = td.text.strip.gsub(/\s+/,' ')
        next if ['&nbsp;',''].include? val
        next if val.match(/^ $/).present?
        key = td.previous_element().text.strip.sub(/：/,'')
        meta[key] = val
      end
      meta.delete "证书及荣誉"
      meta.delete "工商注册信息"
      meta["公司主页"] = meta["公司主页"].gsub(homeurl,"").strip if meta.has_key? "公司主页"
      data[:meta] = meta
      data[:desc] = doc.at_css("#company-more").text.strip rescue nil
      #logm data
      Company.import_data data
    end
    def parse_company_old ali_url
      homeurl = "http://#{ali_url}.cn.alibaba.com"
      url = "#{homeurl}/page/companyinfo.htm"
      page = http.fetch_page url
      return false if page.code != 200
      doc = page.doc
      data = {
        :ali_url => ali_url
      }
      meta = {}
      data[:name] = doc.at_css(".info-company-title span").text.strip rescue nil
      return false if data[:name].nil?
      doc.xpath("//td[@class='tdvalue']").each do |td|
        val = td.text.strip.gsub(/\s+/,' ')
        next if val.match(/^ $/).present?
        key = td.previous_element().text.strip.sub(/：/,'')
        meta[key] = val
      end
      meta.delete "证书及荣誉"
      meta.delete "工商注册信息"
      meta["公司主页"] = meta["公司主页"].gsub(homeurl,"").strip if meta.has_key? "公司主页"
      data[:meta] = meta
      data[:desc] = doc.at_css(".info-body").text.strip rescue nil
      #logm data
      Company.import_data data
    end
    def parse_list url,more=true
      url = "http://search.china.alibaba.com/company/-#{url}.html" unless url =~ /ttp\:\/\//
      page = http.fetch_page url
      find_more_coms page
      find_more_list page if more
    end
    def parse_coms_from_cat cid
      #url = "http://search.china.alibaba.com/selloffer/--#{cid}.htm"
      url = "http://search.china.alibaba.com/company/--#{cid}.html"
      page = http.fetch_page url
      find_more_coms page
    end
    def parse_cats url,more=false
      page = http.fetch_page url
      import_cats page
      find_more_cats page if more
    end
  end
end
