class ApplicationController < ActionController::Base
  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  before_filter :init_city
  include CityHelper::ViewHelper,ApplicationHelper
  def init_city
    unless %w(main).include? controller_name 
      if params[:city_name].present?
        @city_name = params[:city_name] 
        if is_state? @city_name
          @is_state = true
          @city_title = I18n.t("states.#{@city_name}")
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
end
