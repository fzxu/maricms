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

class PagesController < ApplicationController
  before_filter :get_setting
  before_filter :handle_mobile, :only => :show
  before_filter :authenticate_user!, :except => :show
  
  theme :get_theme

  caches_action :show, :cache_path => Proc.new {|c| c.params}
  # GET /pages
  # GET /pages.xml
  def index
    #@pages = Page.all.asc(:position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  def datatable
    @records = current_records(params)
    @total_records = total_records()

    respond_to do |format|
      format.json {render :layout => false}
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    begin
      p_mg_alias = params.delete(:alias)

      if p_mg_alias
        mg_url = MgUrl.where(:path => p_mg_alias)
        if mg_url.count == 1
        @mg_url = mg_url.first
        else
          render :text => "no such alias!"
        return
        end
      end

      if @mg_url && @mg_url.page
      # if there is page bind to alias, use that page
      @page = @mg_url.page
      end

      if params[:id]
        page_alias = MgUrl.where(:path => params[:id])
        if page_alias.count == 1 && page_alias.first.page
        # if there is id also, this page binding should have higher priority
        @page = page_alias.first.page
        end
      end

      # still no page?
      unless @page
        # try to find the 'index' alias for index page
        mg_url = MgUrl.where(:path => 'index')
        if mg_url.count == 1
        @mg_url = mg_url.first
        @page = @mg_url.page
        else
        # no page found, use the very first root instead
        @page = Page.root
        end
      end

      # still still no page??
      unless @page
        render :text => "There is no page combined to this alias or there is no any page at all!"
      return
      end

      if p_mg_alias
        mg_url = MgUrl.where(:path => p_mg_alias)
        if mg_url.count == 1
        @mg_url = mg_url.first
        else
          render :text => "no such alias!"
        return
        end
      end

      #Assemble the variable and it's content, and then pass to template
      render_params = Hash.new
      render_params["#{TEMPLATE_VARIABLE_PREFIX}params"] = params

      # alias query hash
      alias_q = {}
      alias_hash = params # combine the alias hash with the url params

      # try to convert the ds record which bind to the mg_url to query hash
      if @mg_url && !@mg_url.record.is_a?(Page)
        if !@mg_url.record.blank?
          unless alias_q[@mg_url.record.class.d.key]
            alias_q[@mg_url.record.class.d.key] = []
          end
          alias_q[@mg_url.record.class.d.key] << {"_id" => @mg_url.record_id}
        else
          unless @mg_url.param_string.blank?
            @mg_url.param_string.split('&').each do |p_str|
              pair = p_str.strip.split('=')
              alias_hash[pair.first] = pair.last
            end
          end
        end
      else

      end

      # assemble the alias query hash
      alias_hash.each do |k,v|
        s = k.split(".")
        if s && s.size > 2 && s[0] == "ds"
          unless alias_q[s[1]]
            alias_q[s[1]] = []
          end
          alias_q[s[1]] << {s[2] => v}
        end
      end
      
      # actually do the query and add to template
      alias_q.each do |k, v|
        result = D.where(:key => k).first.get_klass
        v.each do |condition|
          result = result.where(condition)
        end
        render_params["#{TEMPLATE_DYNAMIC_DS_PREFIX}#{k}"] = result.paginate(:page => params[:page], :per_page => @page.per_page || 20)
      end

      # datasource query hash
      q = {}
      param_hash = {}


      # Query the datasource based on the parameters
      param_hash.each do |k,v|
        s = k.split(".")
        if s && s.size > 2 && s[0] == "ds"
          unless q[s[1]]
          q[s[1]] = []
          end
          q[s[1]] << {s[2] => v}
        end
      end

      # add the ds to render_params one by one. render_params will be used for template rendering
      r_page_ds = @page.r_page_ds
      if r_page_ds && r_page_ds.size > 0
        for r_page_d in r_page_ds
          d_key = r_page_d.d.key
          unless r_page_d.new_d_name.blank?
          d_key = r_page_d.new_d_name
          end
          if q[d_key].nil?
            render_params[d_key] = r_page_d.default_query.paginate(:page => params[:page], :per_page => @page.per_page || 20)
          else
            result = r_page_d.default_query
            q[d_key].each do |condition|
              result = result.where(condition)
            end
            render_params[d_key] = result.paginate(:page => params[:page], :per_page => @page.per_page || 20)
          end

        end
      end

      # add additional variables needed
      render_params["#{TEMPLATE_VARIABLE_PREFIX}theme_path"] = "/themes/" + get_theme
      render_params["#{TEMPLATE_VARIABLE_PREFIX}current_page"] = @page
      render_params["#{TEMPLATE_VARIABLE_PREFIX}current_lang"] = I18n.locale.to_s
      render_params["#{TEMPLATE_VARIABLE_PREFIX}setting"] = @setting
      render_params["#{TEMPLATE_VARIABLE_PREFIX}current_alias"] = @mg_url
      render_params["#{TEMPLATE_VARIABLE_PREFIX}current_url"] = request.fullpath

      respond_to do |format|
        format.html do
          render :layout => false, :text => get_template(@page).render(render_params, :registers => {:controller => self})
        end
        format.mobile do
          render :layout => false, :text => get_template(@page, "mobile").render(render_params, :registers => {:controller => self})
        end
        format.xml  { render :xml => @page }
      end
    rescue BSON::InvalidObjectId => e
      render :text => "page not found"
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.xml
  def create
    mg_url = params[:page].delete(:mg_url)
    r_page_ds = params[:page].delete(:r_page_ds)
    @page = Page.new(params[:page])

    if r_page_ds && r_page_ds.size > 0

      rpd = []
      r_page_ds.each do |rd|
        unless rd[:d_id].blank?
        r_page_d = RPageD.new(:query_hash => rd[:query_hash])
        r_page_d.d = D.find(rd[:d_id])
        r_page_d.new_d_name = rd[:new_d_name]
        rpd << r_page_d
        end
      end
    @page.r_page_ds = rpd
    end

    # update the mg url
    unless mg_url[:path].blank?
      @page.mg_url = MgUrl.new(mg_url.merge(:page_id => @page.id))
    end

    respond_to do |format|
      if @page.save
        expire_cache_for_page(@page)
        format.html { redirect_to(pages_url, :notice => 'Page was successfully created.') }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update

    r_page_ds = params[:page].delete(:r_page_ds)
    @page = Page.find(params[:id])
    mg_url = params[:page].delete(:mg_url).merge(:page_id => @page.id)

    if r_page_ds && r_page_ds.size > 0

      #remove the old ones
      @page.r_page_ds.destroy_all
      # end remove

      rpd = []
      r_page_ds.each do |rd|
        unless rd[:d_id].blank?
        r_page_d = RPageD.new(:query_hash => rd[:query_hash])
        r_page_d.d = D.find(rd[:d_id])
        r_page_d.new_d_name = rd[:new_d_name]
        rpd << r_page_d
        end
      end
    end

    if mg_url[:path].blank?
      if @page.mg_url
        @page.mg_url.destroy
      end
    else
      if @page.mg_url
        @page.mg_url.update_attributes(mg_url)
      else
        @page.mg_url = MgUrl.new(mg_url)
      end
    end

    respond_to do |format|
      if @page.update_attributes(params[:page].merge({:r_page_ds => rpd}))
        expire_cache_for_page(@page)
        format.html { redirect_to(pages_url, :notice => 'Page was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    @mg_url = @page.mg_url
    if @mg_url
      @mg_url.destroy
    end

    @page.destroy
    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end

  def move_up
    @page = Page.find(params[:id])
    @page.move_up

    respond_to do |format|
      format.html {redirect_to(pages_path)}
      format.js { render "shared/datatable/fnDraw" }
      format.xml  { head :ok }
    end
  end

  def move_down
    @page = Page.find(params[:id])
    @page.move_down

    respond_to do |format|
      format.html { redirect_to(pages_path)}
      format.js { render "shared/datatable/fnDraw" }
      format.xml  { head :ok }
    end
  end

  private

  def current_records(params={})
    result = []

    if params[:sSearch].blank?
      pointer = 0
      counter = 0

      Page.with_scope(Page.asc(:position)) do
        Page.traverse(:depth_first) do |rec|
          if pointer >= params[:iDisplayStart].to_i && counter < params[:iDisplayLength].to_i
          result << rec
          counter += 1
          end
          pointer += 1
        end
      end
    @total_disp_records_size = Page.all.count
    return result
    else
      pointer = 0
      counter = 0
      Page.with_scope(Page.asc(:position)) do
        Page.traverse(:depth_first) do |rec|
          found = false
          rec.fields.each do |field|
            if (rec.send(field.last.name).is_a?(String) && rec.send(field.last.name) =~ /#{params[:sSearch]}/) ||
            ((rec.send(field.last.name).is_a?(Fixnum) || rec.send(field.last.name).is_a?(Float)) && rec.send(field.last.name).to_i.to_s == params[:sSearch])
            found = true

            end
          end
          # support parent
          par = rec.parent
          while par
            if  par.name =~ /#{params[:sSearch]}/
            found = true
            end
            par = par.parent
          end
          if found
            if pointer >= params[:iDisplayStart].to_i && counter < params[:iDisplayLength].to_i
            result << rec
            counter += 1
            end
          pointer += 1
          end
        end
      end
    @total_disp_records_size = pointer
    return result
    end

  end

  def total_records()
    Page.all.count
  end

  def get_template(page, format = nil)
    # for include tag usage
    Liquid::Template.file_system = Liquid::ThemeFileSystem.new(File.join(theme_path, "theme"))
    
    begin
      if format
        begin
          template_content = IO.read(File.join(theme_path, "theme", "#{page.theme_path}.#{format}.html") )
        rescue
          template_content = IO.read(File.join(theme_path, "theme", "#{page.theme_path}.html" ))
        end
      else
        template_content = IO.read(File.join(theme_path, "theme", "#{page.theme_path}.html" ))
      end
    rescue
      template = Liquid::Template.parse("The page template(#{page.theme_path}.#{format}) can not be found!")
      return template
    end
    template = Liquid::Template.parse(template_content)  # Parses and compiles the template
  #TODO need to cache the template somewhere in future
  end
end