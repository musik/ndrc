#encoding: utf-8
class TopicsController < ApplicationController
  def admin
    @topics = Topic.page(params[:page])
    @topics = @topics.where(published: nil) if  params[:published] == "0"
    @topics = @topics.where(published: false) if  params[:published] == "-1"
  end
  def set
    @topics = Topic.where(id: params[:topics])
    case params[:act]
    when 'delete'
      @topics.delete_all
    when 'unpublish'
      @topics.update_all( published: nil)
    when 'hide'
      @topics.update_all( published: false)
    else
      @results = @topics.where(published: [nil,false]).all
      @topics.update_all({published: true,updated_at: Time.now})
      @results.each do |t|
        t.import_companies
      end
    end
    redirect_to request.referer
  end
  def show
    @topic = Topic.find_by_slug params[:id]
    @q= @topic.name
    #@entries =  Entry.search(
        #@topic.name,
        #:page=>params[:page] || 1,
        #:include=>[:text],
        #:sort_mode => :extended,
        #:order => "@relevance DESC",
        #:per_page => 10
        #)
    @companies =  Company.search(
        @topic.name,
        :page=>params[:page],
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 10
        )
    @relates = Topic.search(@topic.name,
                            without: {id: @topic.id},
                            match_mode: :any,per_page: 8)
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
  def category
    @category = Category.find_smart(params[:id])
    @topics = Topic.search(@category.name,
                match_mode: :any,
                :page=>params[:page],
                #:sort_mode => :extended,
                :order => "@relevance DESC",
                :per_page => 100
                )
  end

  def recent
  end

  def hot
  end

  def bydate
  end
end
