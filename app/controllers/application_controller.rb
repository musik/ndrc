#encoding: utf-8
class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  before_filter :init_city#,:jisuan_houzhui
  include CityHelper::ViewHelper,ApplicationHelper
  def jisuan_houzhui
    return
    keywords = %w(www.00game.net tianyanmao.cn www.taoyutaole.com taoyutaole.com 重庆方言网 028成都交友网 www.361.cm 0871交友网 重庆方言网站 上海yy房产网 重庆中学生网 0731长沙交友网 重庆中学生网高考 0773桂林交友网 重庆学生网高考 027旅游招聘网 028成都新闻 blwzd重庆方言 重庆中学生学习网 重庆言子儿网站 blwzd www.yingyuxuexi.net 广场舞wagcw www.anedc.com)
    @key = Digest::MD5.new.hexdigest(request.url)[30,2].to_i(16)
    @suffix = keywords[@key]
    @title_suffix ||= "_" +  @suffix if @suffix.present?
  end
  def init_city
    unless %w(main).include? controller_name 
      if params[:city_name].present?
        @city_name = params[:city_name] 
        if is_state? @city_name
          @is_state = true
          @city_title = I18n.t("states.#{@city_name}")
          params[:l] = @city_title
        elsif is_city? @city_name
          @city_title = I18n.t("cities.#{@city_name}")
          @hide_citynav = true if !is_capital? @city_name

        else
          @city_name = false
        end
      end

      breadcrumbs.add :home,root_url,:rel=>"nofollow"
      breadcrumbs.add @city_title,city_link(@city_name),:rel=>"nofollow" if @city_name
    end
  end
  def _key_auth?
      params[:strToken] == '98fbb9a2bf7f7c8014f836c366019f84'
  end
end
