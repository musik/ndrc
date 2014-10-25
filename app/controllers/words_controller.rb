class WordsController < ApplicationController
  def dump
    @per_page = 10
    if params[:page].present?
      @words = Word.where("name is not null").page(params[:page]).per(@per_page).pluck(:name)
      respond_to do |f|
        f.text {render text: @words.join("\n")}
      end
    else
      @size = Word.where("name is not null").count() 
      dm = @size.divmod(@per_page)
      @pages = dm[0] + (dm[1].zero? ? 0 : 1)
      respond_to do |f|
        f.text {render text: Range.new(1,@pages).to_a.collect{|p| words_dump_url(page: p,format: "txt") }.join("\n")}
        f.html
      end
    end
  end
end
