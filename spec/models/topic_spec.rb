#encoding: utf-8
require 'spec_helper'

describe Topic do
  it "should ensure slug uniq" do
    #pp Topic.create :name=>'b',:slug=>'a'
    #pp Topic.create :name=>'a-1',:slug=>'a'
    #pp Topic.where(:name=>'a-1').first_or_create
    #pp Topic.find_or_create_by_name '9艾条'
    #pp Topic.find_or_create_by_name '09艾条'
    #pp Topic.find_or_create_by_name 'ＰＶＣ护栏'
    #pp "".to_url :replace_whitespace_with=>'|'
    #Topic.first.update!
    #Topic.import_from_csv
  end
end
