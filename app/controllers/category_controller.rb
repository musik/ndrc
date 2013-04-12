#encoding: utf-8
class CategoryController < ApplicationController
  caches_action :city,:expires_in => 5.hours, :cache_path => Proc.new { |c| c.params }

  caches_action :show,:expires_in => 1.hours, :cache_path => Proc.new { |c| c.params }
  caches_action :index,:expires_in => 1.week
  def index
    @roots = Category.roots.includes(:children)
    @hide_cats = true
    breadcrumbs.add "分类",nil
  end

  def popular
  end

  def all
  end

  def show
    @category = Category.find_smart(params[:id])
    params[:page] ||= 1
    @companies =  Company.search(
        @category.name.gsub(/、/,' '),
        :page=>params[:page],
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 10
        )
    if @companies.empty? and params[:page].to_i == 1
      @instead = true
      @companies =  Company.search(
          @category.name.gsub(/、/,' '),
          :include=>[:text],
          :match_mode => :any,
          :sort_mode => :extended,
          :order => "@random",
          :per_page => 10
          )
    end
    if @category.child?
      @category.ancestors.each do |c|
        breadcrumbs.add c.name,cat_link(c)
      end
    end
    @children = @category.leaf? ? @category.siblings : @category.children
    breadcrumbs.add @category.name

    @show_catcities = true
  end
  def city
    @category = Category.find_smart(params[:id])
    @title = "#{@city_title}#{@category.name}公司"
    params[:page] ||= 1
    @companies =  Company.search(
        @category.name,
        :conditions=>{:location=>@city_title},
        :page=>params[:page],
        :include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC",
        :per_page => 10
        )
    if @companies.empty? and params[:page].to_i == 1
      @instead = true
      @companies =  Company.search(
          @category.name,
          :include=>[:text],
          :sort_mode => :extended,
          :order => "@random",
          :per_page => 10
          )
    end
        
    if @category.child?
      @category.ancestors.each do |c|
        breadcrumbs.add c.name,citycat_link(@city_name,c),:rel=>"nofollow"
      end
    end
    #if is_state? @city_name or is_capital? @city_name
      #max_depth = is_state?(@city_name) ? 1 : 0
      #if (!@category.leaf? and @category.depth < max_depth )
        #@children = @category.children
      #else
        #@children = @category.siblings
      #end
    #end
    breadcrumbs.add @category.name
    @show_catcities = true
  end
end
