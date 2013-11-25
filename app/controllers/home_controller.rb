#encoding: utf-8
class HomeController < ApplicationController
  caches_action :index,:expires_in => 5.minutes
  caches_action :city,:expires_in => 5.minutes
  def index
    @hide_cities = true
  end
  def welcome
  end
  def search
    @q = params[:q]
    if @q.blank? && params[:l].blank?
      redirect_to root_url
      return
    end
    @title = @q
    conditions = {}
    if params[:l].present?
      conditions[:location] = params[:l]
      @title = params[:l] + @q
    end
    @companies =  Company.search(
        @q.gsub(/、/,' '),
        :conditions=>conditions,
        :page=>params[:page] || 1,
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 25
        )
    @relates = Topic.search(@q,
                    match_mode: :any,per_page: 9)
    @province_counts = Company.facets(@q,facets: :province_id)[:province_id]
    @provinces = Province.where(id: @province_counts.keys)
    @provinces.each do |r|
      r[:companies_count] = @province_counts[r.id]
    end
    #@groups = Company.search(@q,:group_by=>:location,:order_group_by=>"count(*) desc")
    breadcrumbs.add @title,nil
  end
  def status
    @data = {
      :companies => Company.count,
      :entries => Entry.count,
      :topics => Topic.count
    }
    render :xml=>@data
  end
  def test
    render :text=>Company.fuwus
  end
  def city
    @title = "#{@city_title}黄页"
    @companies =  Company.search(
        :conditions=>{:location=>@city_title},
        :page=>params[:page] || 1,
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC,id desc",
        :per_page => 10
        )

  end
  def cities
    @results = {}
    CityHelper::CITIES[:china].keys.each do |state|
      @results[CGI.escape(I18n.t("states.#{state}"))] = state.to_s
    end
    CityHelper::CITIES[:china].values.flatten.each do |state|
      @results[CGI.escape(I18n.t("cities.#{state}"))] = state.to_s
    end
    respond_to do |format|
      format.text {render :layout=>false}
      #format.text { render text: CGI.unescape(_join_cities(@results)) }
      format.json { render json: CGI.unescape(@results.to_json) }
    end
  end
  def topic
    @name = params[:id]
    @title = @name
    @companies =  Company.search(
        @name.gsub(/、/,' '),
        :page=>params[:page] || 1,
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 25
        )
  end
  def _join_cities hash,a=':',b=','
    arr = []
    hash.each do |k,v|
      arr << "#{k}#{a}#{v}"
    end
    arr.join('|')
  end
end
