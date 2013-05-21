class EntriesController < ApplicationController
  def show
    @entry = Entry.find params[:id]
  end

  def index
  end

  def recent
  end

  def hot
  end

  def bydate
  end
end
