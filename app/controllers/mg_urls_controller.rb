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

class MgUrlsController < ApplicationController
  before_filter :get_setting
  before_filter :authenticate_user!
  
  # GET /mg_aliases
  # GET /mg_aliases.xml
  def index
    #@mg_aliases = MgAlias.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  #{ render :xml => @mg_aliases }
    end
  end

  def datatable
    @records = current_records(params)
    @total_records = total_records()

    respond_to do |format|
      format.json {render :layout => false}
    end
  end

  # GET /mg_aliases/1
  # GET /mg_aliases/1.xml
  def show
    @mg_url = MgUrl.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mg_url }
    end
  end

  # GET /mg_aliases/new
  # GET /mg_aliases/new.xml
  def new
    @mg_url = MgUrl.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mg_url }
    end
  end

  # GET /mg_aliases/1/edit
  def edit
    @mg_url = MgUrl.find(params[:id])
  end

  # POST /mg_aliases
  # POST /mg_aliases.xml
  def create
    @mg_url = MgUrl.new(params[:mg_url])

    respond_to do |format|
      if @mg_url.save
        format.html { redirect_to(mg_urls_path, :notice => 'Mg alias was successfully created.') }
        format.xml  { render :xml => @mg_url, :status => :created, :location => @mg_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mg_url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mg_aliases/1
  # PUT /mg_aliases/1.xml
  def update
    @mg_url = MgUrl.find(params[:id])
    expire_action_cache(@mg_url)
    
    respond_to do |format|
      if @mg_url.update_attributes(params[:mg_url])
        #Expire both the old path cache and the new path cache (because it is possible that the new path is already cached before)
        
        expire_action_cache(@mg_url)
        format.html { redirect_to(mg_urls_path, :notice => 'Mg alias was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mg_url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mg_aliases/1
  # DELETE /mg_aliases/1.xml
  def destroy
    @mg_url = MgUrl.find(params[:id])
    expire_action_cache(@mg_url)
    @mg_url.destroy
    
    respond_to do |format|
      format.html { redirect_to(mg_urls_url) }
      format.xml  { head :ok }
    end
  end

  private
  
  def current_records(params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1

    if params[:sSearch].blank?
      result = MgUrl.all
    else
      result = MgUrl.any_of(conditions(params))
    end
    @total_disp_records_size = result.size

    result.desc(:position).paginate :page => current_page,
    :per_page => params[:iDisplayLength]
  end
  
  def total_records
    MgUrl.all.size
  end

  def conditions(params={})
    cond = []
    sSearch = params[:sSearch]
    MgUrl.fields.each do |field|
      if  field.last.type == "Integer" && sSearch.to_i.to_s == sSearch
        cond << {"#{field.last.name}".to_sym => sSearch.to_i}
      elsif
        cond << {"#{field.last.name}".to_sym => /#{sSearch}/}
      end
    end
    return cond
  end

  def expire_action_cache(a)
    expire_fragment(/\S+#{a.path}/)
    expire_fragment(/\S+\/index/)
    expire_fragment(/\S+\/.mobile/)    
  end
end
