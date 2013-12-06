#encoding: utf-8
module Bot1688
  class Index
    include ResqueEx
    @queue = 'index'
    def fetch_all
      get_cats.each do |cat|
        async :get_cat,cat
      end
    end
    def get_cats
      url = "http://index.1688.com/alizs/keyword.htm"
      page = Anemone::HTTP.new.fetch_page(url)
      raise "Bot1688::Index root fetch error: #{page.url}" if !page.fetched?
      return if page.code != 200
      cats = []
      page.doc.css('.cate-list li a').each do |a|
        cats << a.attr("data-key").to_i
      end
      cats
    end
    def get_cat cat
      %w(rise hot new word).product(%w(week month)).each do |arr|
        async :get_words,cat,arr[0],arr[1]
      end
    end
    def get_words cat,type='rise',period='week'
      url = "http://index.1688.com/alizs/word/listRankType.json?cat=#{cat}&rankType=#{type}&period=#{period}"
      page = Anemone::HTTP.new.fetch_page(url)
      raise "Bot1688::Index page fetch error: #{page.url}" if !page.fetched?
      return if page.code != 200
      str = JSON.parse(page.body)["content"].collect{|hash|
        hash["keyword"]
      }.join(';').gsub(/ /,'')
      Topic.import_from_str str,true
    end
  end
end
