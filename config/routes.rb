
class CityConstraint
  include CityHelper::ViewHelper
  def initialize
  end
  def matches? request
    #Rails.logger.debug request.params
   is_city_or_state? request.params[:city_name]
  end
end
Hy::Application.routes.draw do
  get "home/topic"

  resources :companies,:path=>"qiye",:except=>[:show]

  get "fenlei" => "category#index"
  get "category/popular"
  get "category/all"
  get "fenlei-:id" => "category#show"
  get "qiye-:id" => "companies#show"
  get "t-:id" => "home#topic"
  get "cities" => "home#cities"

  get "home/city"

  #include CityHelper 

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  authenticated :user do
    #root :to => 'home#index'
  end
  get "/:city_name-qiye" => "companies#city" ,:constraints=>CityConstraint.new 
  get "/:city_name-:id" => "category#city" ,:constraints=>CityConstraint.new 
  scope '/:city_name',:constraints=>CityConstraint.new do
    get "/c-:id"=>"category#city"
    root :to=>"home#city"
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
end