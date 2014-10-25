class WordsController < ApplicationController
  def dump
    @words = Word.where("name is not null").pluck(:name)
    respond_to do |f|
      f.text {render text: @words.join("\n")}
    end
  end
end
