class CatsController < ApplicationController
  # GET /cats
  # GET /cats.json
  def index
    @cats = Cat.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cats }
    end
  end

  # GET /cats/1
  # GET /cats/1.json
  def show
    @cat = Cat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cat }
    end
  end

  # GET /cats/new
  # GET /cats/new.json
  def new
    @cat = Cat.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cat }
    end
  end

  # GET /cats/1/edit
  def edit
    @cat = Cat.find(params[:id])
  end

  # POST /cats
  # POST /cats.json
  def create
    @cat = Cat.new(params[:cat])

    respond_to do |format|
      if @cat.save
        _update_topics 
        format.html { redirect_to action: "new", notice: 'Cat was successfully created.' }
        format.json { render json: @cat, status: :created, location: @cat }
      else
        format.html { render action: "new" }
        format.json { render json: @cat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cats/1
  # PUT /cats/1.json
  def update
    @cat = Cat.find(params[:id])

    respond_to do |format|
      if @cat.update_attributes(params[:cat])
        _update_topics 
        format.html { redirect_to action: "edit", notice: 'Cat was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cat.errors, status: :unprocessable_entity }
      end
    end
  end
  def _update_topics
    names = params[:topics].split(" ")
    if names
      Topic.where(name: names).update_all cat_id: @cat.id
    end
    names = @cat.recommended.split(" ").compact
    if names
      Topic.where(name: names).update_all level: 1
    end
  end
  def _update_topic_names names,level = nil
    names = names.split(" ")
    return if !names
    @topics = Topic.where(name: names)
    @topics.each_with_index do |t,i|
      t.cat = @cat
      t.priority = i
      #t.level = level
      t.save
    end
  end

  # DELETE /cats/1
  # DELETE /cats/1.json
  def destroy
    @cat = Cat.find(params[:id])
    @cat.destroy

    respond_to do |format|
      format.html { redirect_to cats_url }
      format.json { head :no_content }
    end
  end
end
