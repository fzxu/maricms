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

class DsController < ApplicationController
  before_filter :get_setting
  before_filter :authenticate_user!
  
  # GET /ds
  # GET /ds.xml
  def index
    #@ds = D.all
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @ds }
    end
  end

  def datatable
    @records = current_records(params)
    @total_records = total_records()

    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  # GET /ds/1
  # GET /ds/1.xml
  def show
    @d = D.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @d }
    end
  end

  # GET /ds/new
  # GET /ds/new.xml
  def new
    @d = D.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @d }
    end
  end

  # GET /ds/1/edit
  def edit
    @d = D.find(params[:id])
    @ds_element = DsElement.new
  end

  # POST /ds
  # POST /ds.xml
  def create
    @d = D.new(params[:d])

    respond_to do |format|
      if @d.save
        format.html { redirect_to(@d, :notice => 'D was successfully created.') }
        format.xml  { render :xml => @d, :status => :created, :location => @d }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @d.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ds/1
  # PUT /ds/1.xml
  def update
    @d = D.find(params[:id])
    new_ds_elements = params[:d].delete(:ds_elements)
    unless new_ds_elements.blank?
      new_ds_elements.each do |key, value|
        element = @d.ds_elements.find(key)
        element.update_attributes(value)
      end
    end

    respond_to do |format|
      if @d.update_attributes(params[:d])
        format.html { redirect_to(edit_d_path(@d)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @d.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ds/1
  # DELETE /ds/1.xml
  def destroy
    @d = D.find(params[:id])
    @d.destroy
    
    respond_to do |format|
      format.html { redirect_to(ds_url) }
      format.xml  { head :ok }
    end
  end

  def create_ds_element
    @d = D.find(params[:id])
    ds_element = DsElement.new(params[:ds_element])
    @d.ds_elements << ds_element

    respond_to do |format|
      if @d.save
        format.html { redirect_to(edit_d_path(@d)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @d.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy_ds_element
    @d = D.find(params[:id])
    ds_element_id = params[:ds_element_id]
    ds_element = @d.ds_elements.find(ds_element_id)
    ds_element.destroy

    respond_to do |format|
      if @d.save
        format.html { redirect_to(edit_d_path(@d)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @d.errors, :status => :unprocessable_entity }
      end
    end
  end

  def manage
    @d = D.find(params[:id])

    respond_to do |format|
      format.html { redirect_to :controller => "ds_#{@d.ds_type.pluralize.downcase}", :action => "index", :d => @d.id }
      format.xml  { render :xml => @d }
    end
  end

  def move_up
    @d = D.find(params[:id])
    @d.move_up

    respond_to do |format|
      format.html { redirect_to(ds_path) }
      format.js { render "shared/datatable/fnDraw" }
      format.xml  { head :ok }
    end
  end

  def move_down
    @d = D.find(params[:id])
    @d.move_down

    respond_to do |format|
      format.html { redirect_to(ds_path) }
      format.js { render "shared/datatable/fnDraw" }
      format.xml  { head :ok }
    end
  end

  def get_ds_elements
    @d = D.where(:key => params[:id]).first
    @ds_r_elements = @d.ds_elements.where(:ftype => "Relation")
    @ds_nr_elements = @d.ds_elements.where(:ftype.ne => "Relation")
    
    render :layout => false
  end
  
  def get_options_for_select
    @d = D.find(params[:id])
    @disp_field = params[:disp_field]
    @current_record_id = params[:current_record_id]
    
    render :layout => false
  end
  
  private
  
  def current_records(params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1

    unless params[:sSearch].blank?
      result = D.any_of(conditions(params))
    else
      result = D.all
    end
    @total_disp_records_size = result.size

    result.asc(:position).paginate :page => current_page,
    :per_page => params[:iDisplayLength]
  end
  
  def total_records
    D.all.count
  end

  def conditions(params={})
    cond = []
    sSearch = params[:sSearch]
    Page.fields.each do |field|
      if  field.last.type == "Integer" && sSearch.to_i.to_s == sSearch
        cond << {"#{field.last.name}".to_sym => sSearch.to_i}
      elsif
        cond << {"#{field.last.name}".to_sym => /#{sSearch}/}
      end
    end
    return cond
  end
  
end
