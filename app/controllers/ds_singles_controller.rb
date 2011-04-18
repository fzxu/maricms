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

class DsSinglesController < ApplicationController
  before_filter :get_setting
  before_filter :authenticate_user!
  
  # GET /ds_singles
  # GET /ds_singles.xml
  def index
    @d = D.find(params[:d])
    @record = @d.get_klass.first || @d.get_klass.new

    respond_to do |format|
      format.html { render :layout => "ds_view_#{@d.ds_view_type.downcase}"}
      format.xml  { render :xml => @record }
    end
  end

  # POST /ds_singles
  # POST /ds_singles.xml
  def create
    mg_url = params[:record].delete(:mg_url)
  
    @d = D.find(params[:d])
    @record = @d.get_klass.first
    unless @record
      @record = @d.get_klass.new(params[:record])
    end

    unless mg_url[:path].blank?
      @record.mg_url = MgUrl.new(mg_url) unless @record.mg_url
    end
    
    respond_to do |format|
      if @record.save && @record.update_attributes(params[:record]) && (@record.mg_url.update_attributes(mg_url) if @record.mg_url)
        format.html { redirect_to(ds_singles_path(:d => @d.id), :notice => 'Ds single was successfully created.') }
        format.xml  { render :xml => @ds_single, :status => :created, :location => @ds_single }
      else
        format.html { render :action => "index", :layout => "ds_view_#{@d.ds_view_type.downcase}" }
        format.xml  { render :xml => @ds_single.errors, :status => :unprocessable_entity }
      end
    end
  end

end
