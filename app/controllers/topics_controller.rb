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
    breadcrumbs.add :sitemap,zeig_url
    breadcrumbs.add @topic.name,nil
  end

  def zeig
    params[:c] ||= "a" 
    @abbr = params[:c]
    @abbr_title = @abbr == "0" ? "0-9" : @abbr.upcase
    @topics = Topic.published.where(abbr: @abbr).recent.page(params[:page])
    breadcrumbs.add "热门关键词",nil
    breadcrumbs.add @abbr_title
  end

  def recent
  end

  def hot
  end

  def bydate
  end
end
