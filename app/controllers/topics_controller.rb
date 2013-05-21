#encoding: utf-8
class TopicsController < ApplicationController
  def show
    @topic = Topic.find_by_slug params[:id]
    @entries =  Entry.search(
        @topic.name,
        :page=>params[:page] || 1,
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 10
        )
    @companies =  Company.search(
        @topic.name,
        #:include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 10
        )
  end

  def index
    @topics = Topic.published.recent.limit(100)
  end

  def recent
  end

  def hot
  end

  def bydate
  end
end
