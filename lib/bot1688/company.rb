#encoding: utf-8
module Bot1688
  class Company
    EXCLUDES = %w(主营产品 仓库信息 是否提供加工/定制 加工方式 工艺 主要销售区域 主要客户群体 质量控制 厂房面积 研发部门人数 年出口额 年营业额 员工人数 服务领域 代理级别 仓库地址 企业类型 公司名称)
    include Resque::Plugins::Async::Method
    def initialize slug
      @url = "http://#{slug}.1688.com/"
      @data = {ali_url: slug}
      self
    end
    def details
      @details ||= fetch_details
      @details
    end
    def fetch_details
      details_url = @url + "page/creditdetail.htm"
      page = Anemone::HTTP.new(redirect_limit: 1).fetch_page details_url
      raise "Bot1688::Company page fetch error: #{page.url}" if !page.fetched?
      return if page.code != 200
      @data[:name] = page.doc.at_css(".company-title span").attr("title")
      @data[:metas] = parse_matas(page.doc)
      #Address
      unless @data[:metas].key?("实际经营地址")
        mapnode = page.doc.search("//a[@map-mod-config]")[0] rescue nil
        if mapnode.present?
          @data[:address] = mapnode.attr("map-mod-config").match(/实际经营地址:(.+?)\"/)[1]
        end
        else
        @data[:address] = @data[:metas].delete("实际经营地址")  
      end
      #Contact
      @data.merge! parse_contact(page.doc)
      @data[:desc] = page.doc.at_css("#company-more").text.strip.sub(/ 收起$/,'') rescue nil
      @data
    end
    #async_method :fetch_details
    def parse_contact doc
      hash = {}
      doc.css("#memberinfo dd span.attrkey").each do |s|
        hash[s.text.gsub(/[ ：]/,'')] = s.next.text.gsub(/\&nbsp/,'').strip
      end
      {contact: "联系人",phone: "固定电话", mobile: "联系电话"}.each do |k,v|
        hash[k] = hash.delete(v)
      end
      hash
    end
    def parse_matas doc
      metas = {}
      doc.xpath("//td[@class='ta2']").each do |td|
        val = td.text.strip.gsub(/\s+/,' ')
        next if val == '&nbsp;' or val.blank?
        next if val.match(/^ $/).present?
        key = td.previous_element().text.strip.sub(/：/,'')
        metas[key] = val
      end
      metas.delete_if{|k,v| Company::EXCLUDES.include? k}
      metas["实际经营地址"].sub!(' 查看地图 地图','') if metas["实际经营地址"].present?
      metas
    end
    class << self
      def search q
        List.new(q)
      end
    end
    class List
      attr_accessor :links,:slugs
      def initialize q
        @q = q
        url = "http://s.1688.com/company/company_search.htm?keywords=#{CGI.escape(q.encode('GBK','UTF-8'))}"
        page = Anemone::HTTP.new.fetch_page url
        @slugs = []
        if page.fetched?
          page.doc.css(".sm-offerResult h2 a.sw-ui-font-title14").each do |a|
            u = a['href']
            next if u.nil? or u.empty?
            @slugs << clean_slug(u)
          end
          @slugs.uniq!
        end
      end
      def clean_link u
        u.match(/^http:\/\/.+?.1688.com/).to_s
      end
      def clean_slug u
        u.match(/^http:\/\/(.+?).1688.com/)[1]
      end
      def links
        @links ||= slugs.collect{|r| "http://#{r}.1688.com" }
      end
    end
  end
end
