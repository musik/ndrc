#encoding: utf-8
class HomeController < ApplicationController
  caches_action :index,:expires_in => 5.minutes
  caches_action :city,:expires_in => 5.minutes
  def index
    @hide_cities = true
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
