class PagesController < ApplicationController
  before_filter :get_setting
  theme :get_theme
  
  caches_action :show, :cache_path => Proc.new { |c| c.params }
  
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
      format.js {render :layout => false}
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    begin
      if params[:id]
        @page = Page.find(:first, :conditions => {:slug => params[:id]}) || Page.find(params[:id])
      else
        @page = Page.root
      end

      unless @page
        render :text => "Please create at least one page"
        return  
      end
      
      begin
        template_content = IO.read(File.join(theme_path, "theme", @page.theme_path ))
      rescue
        template_content = IO.read(File.join(theme_path, "theme", "page_default.html" ))
      end
      template = Liquid::Template.parse(template_content)  # Parses and compiles the template
      #TODO need to cache the template somewhere in future

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
      
      q = {}
      param_hash = params
      
      if @mg_url
        if !@mg_url.record.blank?
          unless q[@mg_url.record.class.d.key]
            q[@mg_url.record.class.d.key] = []
          end
          q[@mg_url.record.class.d.key] << {"_id" => @mg_url.record_id}
        else
          unless @mg_url.param_string.blank?
            @mg_url.param_string.split('&').each do |p_str|
              pair = p_str.strip.split('=')
              param_hash[pair.first] = pair.last
            end
          end
        end
      else
        
      end
      
      #Assemble the variable and it's content, and then pass to template
      render_params = Hash.new
      render_params["params"] = params

      #add the tabs to the template
      # tabs = Array.new
      # Tab.traverse(:depth_first) do |tab|
      #   tabs << tab
      # end
      # render_params["tabs"] = tabs
      # render_params["current_tab"] = @tab

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

      respond_to do |format|
        puts render_params
        format.html { render :layout => "front", :text => template.render(render_params, :registers => {:controller => self})}
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
    @page = Page.find(:first, :conditions => {:slug => params[:id]}) || Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.xml
  def create
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
    @page = Page.find(:first, :conditions => {:slug => params[:id]}) || Page.find(params[:id])

    if r_page_ds.size > 0

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
    @page = Page.find(:first, :conditions => {:slug => params[:id]}) || Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      expire_cache_for_page(@page)
      format.html { redirect_to(pages_url) }
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
end
