#encoding: utf-8
require 'spec_helper'

describe Topic do
  it "should ensure slug uniq" do
    #pp Topic.create :name=>'b',:slug=>'a'
    #pp Topic.create :name=>'a-1',:slug=>'a'
    #pp Topic.where(:name=>'a-1').first_or_create
    #Topic.find_or_create_by_name '艾条'
    #Topic.first.update!
  end
end
