
require 'spec_helper'

describe HyRobot do
  
  before(:each) do
  end
  it "should run" do
   #HyRobot.run
    #HyRobot::Core.new.recheck_pages
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
