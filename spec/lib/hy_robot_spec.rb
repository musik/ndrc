
require 'spec_helper'

describe HyRobot do
  
  before(:each) do
  end
  it "should run" do
   #HyRobot.run
    #HyRobot::Core.new.recheck_pages
    #HyRobot::Core.new.run_topics 'http://china.alibaba.com/'
  end
  it "should be topic" do
    #%w(
      #http://search.china.alibaba.com/selloffer/-D5DAD1F4D3C3C6B7.html?spm=a260k.635.5746641.37
      #http://search.china.alibaba.com/selloffer/-B0ACCCF5-10530.html?spm=a260k.635.5746625.61
    #).each do |url|
      #pp HyRobot::Core.new.is_topic? url
    #end
  end
  it "should run" do
    if 2==1
      @http = Anemone::HTTP.new 
      %w(
      http://search.china.alibaba.com/selloffer/--1045391.html
      http://search.china.alibaba.com/selloffer/--21.html
      http://search.china.alibaba.com/selloffer/--14.html
      http://search.china.alibaba.com/selloffer/--1035636.htm
      ).each do |url|
        logm url
        page = @http.fetch_page(url)
        logm HyRobot::Core.new.parse_cat_page page
        logm HyRobot::Core.new.parse_cats_links page.links
      end
    end
  end
end 
