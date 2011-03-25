class ImageStylesController < ApplicationController
  layout 'setting'
  
  # GET /image_styles
  # GET /image_styles.xml
  def index
    @image_styles = ImageStyle.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @image_styles }
    end
  end

  # GET /image_styles/1
  # GET /image_styles/1.xml
  def show
    @image_style = ImageStyle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @image_style }
    end
  end

  # GET /image_styles/new
  # GET /image_styles/new.xml
  def new
    @image_style = ImageStyle.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @image_style }
    end
  end

  # GET /image_styles/1/edit
  def edit
    @image_style = ImageStyle.find(params[:id])
  end

  # POST /image_styles
  # POST /image_styles.xml
  def create
    parent_id = params.delete(:parent_id)
    @image_style = ImageStyle.new(params[:image_style])
    if parent_id
      @parent_image_style = ImageStyle.find(parent_id)
      @parent_image_style.child_image_styles << @image_style
    end
      
    respond_to do |format|
      if (parent_id && @parent_image_style.save) || @image_style.save
        format.html { redirect_to(edit_image_style_path(@parent_image_style || @image_style), :notice => 'Image style was successfully created.') }
        format.xml  { render :xml => @image_style, :status => :created, :location => @image_style }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @image_style.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /image_styles/1
  # PUT /image_styles/1.xml
  def update
    @image_style = ImageStyle.find(params[:id])
    new_versions = params[:image_style].delete(:versions)
    unless new_versions.blank?
      #@image_style.child_image_styles.destroy_all
      new_versions.each do |key, value|
        #@image_style.child_image_styles << ImageStyle.new(value)
        is = @image_style.child_image_styles.find(key) 
        is.update_attributes(value)
      end
    end

    respond_to do |format|
      if @image_style.update_attributes(params[:image_style])# && @image_style
        format.html { redirect_to(edit_image_style_path(@image_style), :notice => 'Image style was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @image_style.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /image_styles/1
  # DELETE /image_styles/1.xml
  def destroy
    @image_style = ImageStyle.find(params[:id])
    @image_style.destroy

    respond_to do |format|
      format.html { redirect_to(image_styles_url) }
      format.xml  { head :ok }
    end
  end
  
  def destroy_version
    version_id = params[:version_id]
    @image_style = ImageStyle.find(params[:id])
    
    is = @image_style.child_image_styles.find(version_id)
    is.destroy
    
    respond_to do |format|
      format.html { redirect_to(edit_image_style_path(@image_style)) }
      format.xml  { head :ok }
    end

  end
end
