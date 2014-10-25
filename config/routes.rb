class CityConstraint
  include CityHelper::ViewHelper
  def initialize k = 'city_name'
    @k = k
  end
  def matches? request
    #Rails.logger.debug request.params
   is_city_or_state? request.params[@k]
  end
end
Hy::Application.routes.draw do
  get "words/dump-:page"=>"words#dump",as: :words_dump
  get "words/dump"

  resources :cats


  get "/s-:location-:id" => "topics#city" ,as: 'topic_city',:constraints=>CityConstraint.new('location')
  match 's-:id'=>'topics#show',:as=>'topic'
  match 'zeig(-:c(-:page))'=>'topics#zeig',:as=>'zeig',:constraints=>{:page=>/[0-9]+/,:c=>/./}
  #match 'zeig-:c'=>'topics#zeig',:as=>'zeig'
  #match 'zeig'=>'topics#zeig',:as=>'zeig'
  get "tc-:id" => "topics#category"
  resources :entries,:path=>"sell"
  #match 'entry/:id'=>'entries#show',:as=>'entry'

  #match ':controller(/:action)', :controller => /topics|entries/
  resources :topics,:path=>"topics",:except=>[:show] do
    get :manage,on: :collection
    get :recent,on: :collection
    post :save,on: :collection
  end

  resources :snips
  #wash_out :ws

  get "status"=>'home#status'

  resources :companies,:path=>"qiye",:except=>[:show] do
    get :recent,on: :collection
  end

  get "fenlei" => "category#index"
  get "category/popular"
  get "category/all"
  get "fenlei-:id" => "category#show"
  get "qiye-:id" => "companies#show"
  get "t-:id" => "home#topic"
  get "cities" => "home#cities"
  match ':action' => "home",:constraints=>{:action=>/search/}


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
  match 'links' => 'snips#links',:as=>'links'
  root :to => "home#six"
  devise_for :users
  resources :users, :only => [:show, :index]
  resque_constraint = lambda do |request|
    Rails.env.development? or 
      (request.env['warden'].authenticate? and request.env['warden'].user.has_role?(:admin))
  end
  constraints resque_constraint do
    mount Resque::Server.new, :at => "/resque"
  end
  #get "/page-:action" => "home"
end
