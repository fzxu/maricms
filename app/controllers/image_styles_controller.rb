##
# MariCMS
# Copyright 2011 金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
# http://www.maricms.com

# This file is part of MariCMS, an open source content management system.

# MariGold MariCMS is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, version 3 of the License.
# 
# Under the terms of the GNU Affero General Public License you must release the
# complete source code for any application that uses any part of MariCMS
# (system header files and libraries used by the operating system are excluded).
# These terms must be included in any work that has MariCMS components.
# If you are developing and distributing open source applications under the
# GNU Affero General Public License, then you are free to use MariCMS.
# 
# If you are deploying a web site in which users interact with any portion of
# MariCMS over a network, the complete source code changes must be made
# available.  For example, include a link to the source archive directly from
# your web site.
# 
# For OEMs, ISVs, SIs and VARs who distribute MariCMS with their products,
# and do not license and distribute their source code under the GNU
# Affero General Public License, MariGold provides a flexible commercial
# license.
# 
# To anyone in doubt, we recommend the commercial license. Our commercial license
# is competitively priced and will eliminate any confusion about how
# MariCMS can be used and distributed.
# 
# MariCMS is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
# details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with MariCMS.  If not, see <http://www.gnu.org/licenses/>.
# 
# Attribution Notice: MariCMS is an Original Work of software created
# by  金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
##

class ImageStylesController < ApplicationController
  before_filter :authenticate_user!
  
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
      new_versions.each do |key, value|
        is = @image_style.child_image_styles.find(key) 
        is.update_attributes(value)
      end
    end

    respond_to do |format|
      if @image_style.update_attributes(params[:image_style])
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
