class MythemesController < ApplicationController
  # GET /mythemes
  # GET /mythemes.xml
  def index
    @mythemes = Mytheme.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mythemes }
    end
  end

  # GET /mythemes/1
  # GET /mythemes/1.xml
  def show
    @mytheme = Mytheme.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mytheme }
    end
  end

  # GET /mythemes/new
  # GET /mythemes/new.xml
  def new
    @mytheme = Mytheme.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mytheme }
    end
  end

  # GET /mythemes/1/edit
  def edit
    @mytheme = Mytheme.find(params[:id])
  end

  # POST /mythemes
  # POST /mythemes.xml
  def create
    @mytheme = Mytheme.new(params[:mytheme])

    respond_to do |format|
      if @mytheme.save
        format.html { redirect_to(@mytheme, :notice => 'Mytheme was successfully created.') }
        format.xml  { render :xml => @mytheme, :status => :created, :location => @mytheme }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mytheme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mythemes/1
  # PUT /mythemes/1.xml
  def update
    @mytheme = Mytheme.find(params[:id])

    respond_to do |format|
      if @mytheme.update_attributes(params[:mytheme])
        format.html { redirect_to(@mytheme, :notice => 'Mytheme was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mytheme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mythemes/1
  # DELETE /mythemes/1.xml
  def destroy
    @mytheme = Mytheme.find(params[:id])
    @mytheme.destroy

    respond_to do |format|
      format.html { redirect_to(mythemes_url) }
      format.xml  { head :ok }
    end
  end
end
