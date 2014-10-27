#encoding: utf-8
require 'anemone/page_ex'
require 'anemone'
class Word < ActiveRecord::Base
  attr_accessible :name, :url
  class Ali
    def initialize
      @http = Anemone::HTTP.new
    end
    def fetch_words max = 1000
      urls = Word.where(name: nil).limit(100).pluck(:url)
      urls = "http://www.1688.com" if urls.empty?
      begin
        run urls,max do |page|
          m = page.doc.title.match(/(.+?)_(.+?)批发_/)
          #next unless m.present?
          e = Word.where(url: page.url.to_s).first
          name = m.present? ? m[1].gsub(" ",'') : '--'
          pp name if Rails.env.test?
          e.present? ? e.update_attributes(name: name) : Word.create(url: page.url.to_s,name: name)
        end
        urls = Word.where(name: nil).limit(100).pluck(:url)
      end while urls.present? and !Rails.env.test?
      Word.count
    end
    def run url,max = 10
      options = { 
        :accept_cookies => true,
        :read_timeout => 60,
        :retry_limit => 0,
        :verbose => true,
        #:discard_page_bodies => true,
        :user_agent => 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0);',
        :delay => 0.9,
        #:storage=> Anemone::Storage.SQLite3(Rails.root.to_s + "/db/pages_#{Rails.env}.sqlite3")

        #:pages_queue_limit => max
      }
      begin
        fetched = 0
        errors = 0
        Anemone.crawl(url, options) do |anemone|
          anemone.focus_crawl do |page|
            #pp page.ali_links
            page.ali_links.collect{|r| 
              m = r.to_s.match(/http:\/\/s.1688.com\/selloffer\/--*([\w]+).html/)
              if m.present?
                Word.where(url: m.to_s).first_or_create.name.present? ? nil : URI(m.to_s)
              else
                nil
              end
            }.compact
          end
          anemone.on_pages_like /selloffer/ do |page|
            fetched += 1 unless max.zero?
            p Time.now if Rails.env.test?
            yield page
            return if fetched >= max
          end
          anemone.on_every_page do |page|
            pp page.code if page.code != 200
            errors +=1 if page.code != 200
            (p "302*#{errors}" and sleep 900 and return) if errors > 5
          end
        end
      rescue Exception => e
        pp e
      end
    end
  end
end
