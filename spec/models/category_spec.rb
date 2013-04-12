#encoding: utf-8
require 'spec_helper'

describe Category do
  it "should create" do
    if 1==1 
      %w(广东 一大 东莞 机械及行业设备 礼品、工艺品、饰品 首饰、饰品).each do |str|
        pp Category.create :name=>str
      end
    end
  end
end
