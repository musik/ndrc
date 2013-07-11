
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
        yjb4321
      ).each do |url|
        Ali::Robot.new.parse_company url
      end
    end
  end
  it "should parse info" do
    if 1==1
        [
          "428434350",
      "1008412155",
 "1228235391",
 "1232497426",
 "1188621543",
 "714813151",
 "859876848",
 "745884210",
 "587433003",
 "1101516030",
 "1231577132",
 "1130163689"].each do |id|
        Ali::Robot.new.parse_info id
        break
      end
    end
  end
end 
