require 'spec_helper'

describe Word do
  it "should fetch " do
    Word::Ali.new.fetch_words 10
  end
end
