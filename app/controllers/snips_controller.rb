class SnipsController < ApplicationController
  load_and_authorize_resource :except=>[:links]
  # GET /snips
  # GET /snips.json
  def index
    authorize! :create,Snip
    @snips = Snip.page(params[:page] || 1)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @snips }
    end
  end
  def links

  end

  # GET /snips/1
  # GET /snips/1.json
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @snip }
    end
  end

  # GET /snips/new
  # GET /snips/new.json
  def new
    @snip = Snip.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @snip }
    end
  end

  # GET /snips/1/edit
  def edit
    @snip = Snip.find(params[:id])
  end

  # POST /snips
  # POST /snips.json
  def create
    @snip = Snip.new(params[:snip])

    respond_to do |format|
      if @snip.save
        format.html { redirect_to @snip, notice: 'Snip was successfully created.' }
        format.json { render json: @snip, status: :created, location: @snip }
      else
        format.html { render action: "new" }
        format.json { render json: @snip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /snips/1
  # PUT /snips/1.json
  def update
    @snip = Snip.find(params[:id])

    respond_to do |format|
      if @snip.update_attributes(params[:snip])
        format.html { redirect_to @snip, notice: 'Snip was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @snip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snips/1
  # DELETE /snips/1.json
  def destroy
    @snip = Snip.find(params[:id])
    @snip.destroy

    respond_to do |format|
      format.html { redirect_to snips_url }
      format.json { head :no_content }
    end
  end
end
