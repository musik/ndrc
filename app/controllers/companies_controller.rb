#encoding: utf-8
class CompaniesController < ApplicationController
  authorize_resource :except=>%w(recent city) ,:unless=> :_key_auth?
  caches_action :show,:expires_in => 1.day
  caches_action :city,:expires_in => 1.hour, :cache_path => Proc.new { |c| c.params }
  caches_action :index,:expires_in => 1.day, :cache_path => Proc.new { |c| c.params }

  # GET /companies
  # GET /companies.json
  def index
    #@companies = Company.recent.includes(:text).page(params[:page] || 1).per(120)
    @recent = Company.recent.limit(30)
    @random = Company.search order: "@random",per_page: 30
   @title = "企业名录"
   breadcrumbs.add @title,companies_url,:rel=>"nofollow"
   breadcrumbs.add "第#{params[:page]}页",nil  if params[:page]
   @hide_paginate = true
  end
  def recent
    #@companies = Company.recent.page(params[:page]).per(120)
   @companies = Company.search page: params[:page],order: "id desc",
        per_page: 100
   breadcrumbs.add "企业名录",companies_url,:rel=>"nofollow"
   breadcrumbs.add "最新注册"
   breadcrumbs.add "第#{params[:page]}页",nil  if params[:page]
  end
  def city
    @companies =  Company.search(
        :conditions=>{:location=>@city_title},
        :page=>params[:page] || 1,
        #:include=>[:text],
        :sort_mode => :extended,
        :order => "@relevance DESC,id desc",
        :per_page => 50
        )
   @title = "#{@city_title}企业名录"
   breadcrumbs.add "企业名录"
    #render "city-index"
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @company = Company.find_by_ali_url(params[:id])
    #@related = Company.any.search [@company.name,@company.fuwu,@company.hangye].join(','),
    @related = Company.any.search @company.short_name,
        :without=>{id:@company.id},:per_page=>9,
        :include=>[:text]

    @title = @company.name
    @title = "[#{@company.short_name}]#{@title}" unless @company.short_name == @title
    @page_title = [@title,@company.hangye,@company.fuwu].compact.slice(0,2).join(":").truncate(40)
    breadcrumbs.add @company.province.name,url_for(@company.province.pinyin) if @company.province.present?
    breadcrumbs.add @company.name
    #jisuan_houzhui
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/new
  # GET /companies/new.json
  def new
    @company = Company.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/1/edit
  def edit
    @company = Company.find(params[:id])
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = params[:company].present? ? 
      Company.new(params[:company]) :
      Company.import_from_tz(params[:data])
    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render json: @company, status: :created, location: @company }
      else
        format.html { render action: "new" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /companies/1
  # PUT /companies/1.json
  def update
    @company = Company.find(params[:id])

    respond_to do |format|
      if @company.update_attributes(params[:company])
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    respond_to do |format|
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end
end
