#encoding: utf-8
class TopicsController < ApplicationController
  def manage
    authorize! :manage,Topic
    @topics = Topic.page(params[:page]).per(500)
    @topics = @topics.where(published: nil) if  params[:published] == "0"
    @topics = @topics.where(published: false) if  params[:published] == "-1"
    @topics = @topics.where(published: true) if  params[:published] == "1"
    @topics = @topics.where("LENGTH(name) = ?",params[:length]) if  params[:length].present?
    @topics = @topics.where("name like ?","%#{params[:special]}%") if params[:special].present?
    @topics = @topics.where("name like ?","%#{params[:end]}") if params[:end].present?
    @topics = @topics.where("name like ?","#{params[:start]}%") if params[:start].present?
    @topics = @topics.order("CHAR_LENGTH(name)")
  end
  def save
    authorize! :manage,Topic
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
    @companies =  Company.search(
        @topic.name,
        :page=>params[:page] || 1,
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 10
        )
    @entries =  Entry.search(
        @topic.name,
        :page=>1,
        #:include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 10
        )
    @relates = Topic.search(@topic.name,
                            without: {id: @topic.id},
                            match_mode: :any,per_page: 20)
    breadcrumbs.add :sitemap,zeig_url
    breadcrumbs.add @topic.name,nil
  end
  def city
    @topic = Topic.find_by_slug params[:id]
    with = {}
    @province = Province.find_by_pinyin(params[:location])
    with[:province_id] = @province.id if @province.present?
    @name = @province.short_name + @topic.name

    @q= @topic.name
    @companies =  Company.search(
        @topic.name,
        with: with,
        :page=>params[:page],
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 10
        )
    @relates = Topic.search(@topic.name,
                            without: {id: @topic.id},
                            match_mode: :any,per_page: 30)
    breadcrumbs.add :sitemap,zeig_url
    breadcrumbs.add @topic.name,topic_url(@topic.slug)
    breadcrumbs.add @province.name
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
    breadcrumbs.add "热门关键词",zeig_url
    breadcrumbs.add @category.name
  end

  def recent
    breadcrumbs.add "热门关键词",zeig_url
    breadcrumbs.add "最新搜索",nil
    @topics = Topic.search(order: "id desc",per_page: 100,page: params[:page])
  end

  def hot
  end

  def bydate
  end
end
