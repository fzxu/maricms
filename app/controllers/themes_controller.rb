class ThemesController < ApplicationController
  # GET /themes
  # GET /themes.xml
  def index
    @themes = Theme.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @themes }
    end
  end

  # GET /themes/1
  # GET /themes/1.xml
  def show
    @theme = Theme.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @theme }
    end
  end

  # GET /themes/new
  # GET /themes/new.xml
  def new
    @theme = Theme.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @theme }
    end
  end

  # GET /themes/1/edit
  def edit
    @theme = Theme.find(params[:id])
  end

  # POST /themes
  # POST /themes.xml
  def create
    @theme = Theme.new(params[:theme])

    respond_to do |format|
      if @theme.save
        format.html { redirect_to(@theme, :notice => 'Theme was successfully created.') }
        format.xml  { render :xml => @theme, :status => :created, :location => @theme }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /themes/1
  # PUT /themes/1.xml
  def update
    @theme = Theme.find(params[:id])

    respond_to do |format|
      if @theme.update_attributes(params[:theme])
        format.html { redirect_to(@theme, :notice => 'Theme was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /themes/1
  # DELETE /themes/1.xml
  def destroy
    @theme = Theme.find(params[:id])
    @theme.destroy

    respond_to do |format|
      format.html { redirect_to(themes_url) }
      format.xml  { head :ok }
    end
  end
end
