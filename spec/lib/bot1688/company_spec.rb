#encoding: utf-8
require 'spec_helper'

describe Bot1688::Company do
  it "should fetch details" do
    slugs = Bot1688::Company.search("美体仪器").slugs
    slugs[0,20].each do |s|
      Bot1688::Company.new(s).details
    end

  end
end
