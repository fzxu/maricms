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

class DsListsController < ApplicationController
  before_filter :get_setting
  before_filter :authenticate_user!
  def index
    @d = D.find(params[:d])

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.js {
        @disp_field =  params[:disp_field]
        render "index_js", :layout => false, :content_type => "text/html"
      }
      format.xml  { render :xml => @tabs }
    end
  end

  def datatable
    @d = D.find(params[:d])
    @records = current_records(@d, params)
    @total_records = total_records(@d)

    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def new
    @d = D.find(params[:d])
    @record = @d.get_klass.new

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.js { render "new_js", :layout => false, :content_type => "text/html" }
      format.xml  { render :xml => @record }
    end
  end

  def create
    mg_url = params[:record].delete(:mg_url)

    @d = D.find(params[:d])
    @record = @d.get_klass.new()

    # update the mg url
    unless mg_url[:path].blank?
      @record.mg_url = MgUrl.new(mg_url)
    end

    # process the relationship
    @d.ds_elements.each do |ds_element|
      if ds_element.ftype == "Relation"
        if ds_element.relation_type == "has_one" || ds_element.relation_type == "belongs_to"
          p_related_record = params[:record].delete("#{ds_element.key}")
          if p_related_record && !p_related_record.blank?
            related_record = D.where(:key => ds_element.relation_ds).first.get_klass.find(p_related_record)
            @record.send("#{ds_element.key}=", related_record)
          end
        elsif ds_element.relation_type == "has_many" || ds_element.relation_type == "has_and_belongs_to_many"
          p_related_records = params[:record].delete("#{ds_element.key}")
          if p_related_records && !p_related_records.empty?
            related_records = []
            p_related_records.each do |p_related_record|
              related_record = D.where(:key => ds_element.relation_ds).first.get_klass.find(p_related_record)
              related_records << related_record
            end
            @record.send("#{ds_element.key}=", related_records)
          end          
        end
      end
    end

    respond_to do |format|
      if @record.update_attributes(params[:record]) && @record.save
        expire_action_cache(@record)
        format.html { redirect_to(ds_lists_path(:d => @d.id))}
        format.js {
          render "shared/close_dialog"
        }
        format.xml { head :ok}
      else
        format.html {render :new, :layout => "ds_view_#{@d.ds_view_type.downcase}"}
        format.xml { render :xml => @record.erros, :status => :unprocessable_entity}
      end
    end
  end

  def edit
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @record }
    end
  end

  def update
    mg_url = params[:record].delete(:mg_url)

    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    if mg_url[:path].blank?
      if @record.mg_url
      @record.mg_url.destroy
      end
    else
      if @record.mg_url
      @record.mg_url.update_attributes(mg_url)
      else
      @record.mg_url = MgUrl.new(mg_url)
      end
    end

    # process the relationship
    @d.ds_elements.each do |ds_element|
      if ds_element.ftype == "Relation"
        if ds_element.relation_type == "has_one" || ds_element.relation_type == "belongs_to"
          p_related_record = params[:record].delete("#{ds_element.key}")
          if p_related_record && !p_related_record.blank?
            related_record = D.where(:key => ds_element.relation_ds).first.get_klass.find(p_related_record)
            @record.send("#{ds_element.key}=", related_record)
          end
        elsif ds_element.relation_type == "has_many" || ds_element.relation_type == "has_and_belongs_to_many"
          p_related_records = params[:record].delete("#{ds_element.key}")
          if p_related_records && !p_related_records.empty?
            related_records = @record.send("#{ds_element.key}")
            @record.send("#{ds_element.key}").nullify && @record.save
            p_related_records.each do |p_related_record|
              related_record = D.where(:key => ds_element.relation_ds).first.get_klass.find(p_related_record)
              related_records << related_record
            end
          else
            @record.send("#{ds_element.key}").nullify
          end          
        end
      end
    end

    respond_to do |format|
      if @record.update_attributes(params[:record])
        expire_action_cache(@record)
        format.html { redirect_to(ds_lists_path(:d => @d.id)) }
        format.xml  { head :ok }
      else
        format.html { render :edit, :layout => "ds_view_#{@d.ds_view_type.downcase}"}
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @mg_url = @record.mg_url
    @record.destroy
    if @mg_url
    @mg_url.destroy
    end

    respond_to do |format|
      expire_action_cache(@record)
      format.html { redirect_to(ds_lists_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end

  def show
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @record }
    end
  end

  def move_up
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.move_up

    respond_to do |format|
      expire_action_cache(@record)
      format.html { redirect_to(ds_lists_path(:d => @d.id)) }
      format.js { render "shared/datatable/fnDraw" }
      format.xml  { head :ok }
    end
  end

  def move_down
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.move_down

    respond_to do |format|
      expire_action_cache(@record)
      format.html { redirect_to(ds_lists_path(:d => @d.id)) }
      format.js { render "shared/datatable/fnDraw" }
      format.xml  { head :ok }
    end
  end

  private

  def current_records(d, params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1

    if params[:sSearch].blank?
    result = d.get_klass.all
    else
      result = d.get_klass.any_of(conditions(d, params))
    end
    @total_disp_records_size = result.size

    result.desc(:position).paginate :page => current_page,
    :per_page => params[:iDisplayLength]
  end

  def total_records(d)
    d.get_klass.all.size
  end

  def conditions(d, params={})
    cond = []
    sSearch = params[:sSearch]
    d.get_klass.fields.each do |field|
      if  field.last.type == "Integer" && sSearch.to_i.to_s == sSearch
        cond << {"#{field.last.name}".to_sym => sSearch.to_i}
      elsif
      cond << {"#{field.last.name}".to_sym => /#{sSearch}/}
      end
    end
    return cond
  end

end
