module Anemone
  module PageEx
    def conv(encoding)
      pattern = Regexp.new("charset=#{encoding}",Regexp::IGNORECASE)
      if @body.match(pattern).present?
        @body.encode!('UTF-8',encoding)
        @body.gsub!(pattern,'charset=utf-8')
        @doc = Nokogiri::HTML(@body)
      end
    end
    def ali_links
      return @links unless @links.nil?
      conv('gbk')
      @links = []
      return @links if !doc

      doc.search("//a[@href]").each do |a|
        u = a['href']
        next if u.nil? or u.empty?
        abs = to_absolute(u) rescue next
        @links << abs if in_alibaba?(abs)
      end
      @links.uniq!
      @links
    end    
    def in_alibaba?(uri)
      uri.host.match(/.+\.1688.com/).present?
    end    
    
  end
end
Anemone::Page.send :include,Anemone::PageEx
