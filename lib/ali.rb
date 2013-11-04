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
    def parse_contact ali_url,doc
      logm data
    end
    def parse_info id
      return if Entry.exists? :ali_id=>id
      url = "http://detail.1688.com/offer/#{id}.html"
      logm url
      page = http.fetch_page url
      return false if page.code != 200
      doc = page.doc
      company_slug = doc.at_css('.top-nav-bar-box a').attr('href').match(/\/\/(.+?)\.1688/)[1]
      company = Company.where(:ali_url=>company_slug).select(:id).first
      if company.nil?
        company = parse_contact company_slug
      end
      data = {
        :ali_id => id,
        :title => doc.at_css('h1').text(),
      }
      prices = doc.css('#mod-detail-price tbody tr').collect do |tr|
        JSON.parse(tr.attr('data-range')) if tr.attr('data-range').present?
      end.compact
      data[:price] = prices.first["price"] if prices.present?
      data[:location_name] = doc.at_css('.mod-detail-parcel .de-line-r').text().split(' ').compact.join(' ') rescue nil

      features = doc.css('.de-feature').collect{|node| node.text()}.compact.join
      data[:meta] = {
        :prices => prices,
        :features => features
      }
      data[:desc] = parse_info_desc id,company_slug

      logm data
      #Entry.import data
    end
    def parse_info_with_company id
      return if Entry.exists? :ali_id=>id
      url = "http://detail.1688.com/offer/#{id}.html"
      page = http.fetch_page url
      return false if page.code != 200
      doc = page.doc
      company_slug = doc.at_css('.top-nav-bar-box a').attr('href').match(/\/\/(.+?)\.1688/)[1]
      company = parse_company company_slug
      if company.present?
        #logm company
        data = {
          :ali_id => id,
          :company_id => company.id,
          :title => doc.at_css('h1').text(),
        }
        prices = doc.css('#mod-detail-price tbody tr').collect do |tr|
          JSON.parse(tr.attr('data-range')) if tr.attr('data-range').present?
        end.compact
        data[:price] = prices.first["price"] if prices.present?
        data[:location_name] = doc.at_css('.mod-detail-parcel .de-line-r').text().split(' ').compact.join(' ') rescue nil

        features = doc.css('.de-feature').collect{|node| node.text()}.compact.join
        data[:meta] = {
          :prices => prices,
          :features => features
        }
        data[:desc] = parse_info_desc id,company_slug

        #logm data
        Entry.import data
      end
    end
    def parse_info_desc id,company_slug
      url = sprintf 'http://laputa.china.alibaba.com/offer/ajax/OfferDesc.do?offerId=%s&memberId=%s&callback=json_decode',id,company_slug
      #pp url
      page = http.fetch_page url
      return nil if page.code != 200
      JSON.parse(page.body.encode('UTF-8','GBK').match(/^json_decode\((.+)\)$/)[1])["offerDesc"]
    end
    def parse_company ali_url
      e = Company.select("id").where(:ali_url=>ali_url).first
      return e if e.present?
      homeurl = "http://#{ali_url}.cn.alibaba.com"
      url = "#{homeurl}/page/creditdetail.htm"
      #logm url
      page = http.fetch_page url
      return false if page.code != 200
      doc = page.doc
      data = {
        :ali_url => ali_url
      }
      meta = {}
      data[:name] = doc.at_css("title").text.sub(/诚信档案$/,'').strip rescue nil
      return false if data[:name].nil?
      doc.xpath("//td[@class='ta2']").each do |td|
        val = td.text.strip.gsub(/\s+/,' ')
        next if val == '&nbsp;' or val.blank?
        next if val.match(/^ $/).present?
        key = td.previous_element().text.strip.sub(/：/,'')
        meta[key] = val
      end
      locations = doc.at_css('.footer-alibaba').parent().previous_element().text().gsub(/\s+/,' ').match(/地址：(.+)$/)[1].split(' ')
      locations.delete "中国"
      data[:location] = locations.join(" ")
      meta.delete " "
      meta.delete "公司名称"
      meta.delete "证书及荣誉"
      meta.delete "工商注册信息"
      meta["公司主页"] = meta["公司主页"].gsub(homeurl,"").strip if meta.has_key? "公司主页"
      data[:meta] = meta
      data[:desc] = doc.at_css("#company-more").text.strip.sub(/ 收起$/,'') rescue nil
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
