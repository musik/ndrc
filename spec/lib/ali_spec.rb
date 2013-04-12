
require 'spec_helper'

describe Ali do
  
  before(:each) do
  end
  it "should run" do
   #HyRobot.run

    #Ali::Robot.new.init_cats
  end
  it "should run" do
    if 2==1
      %w(
      http://search.china.alibaba.com/selloffer/--1045391.html
      http://search.china.alibaba.com/selloffer/--21.html
      http://search.china.alibaba.com/selloffer/--14.html
      http://search.china.alibaba.com/selloffer/--1035636.htm
      ).each do |url|
        logm url
        Ali::Robot.new.parse_cats url
      end
    end
  end
  it "should parse company" do
    #Ali::Robot.new.run_companies
    #Ali::Robot.new.init_coms
    #
    if 2==1
    Ali::Robot.new.parse_coms_from_cat 1036884
      %w(
        yosungift
        ltbzjw
        xydgysb
      ).each do |url|
        logm url 
        Ali::Robot.new.parse_company url
      end
    end
  end
end 
