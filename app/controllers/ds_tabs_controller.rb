class DsTabsController < ApplicationController
  before_filter :get_setting
  theme :get_theme
  
  caches_action :show, :cache_path => Proc.new { |c| "tabs_#{params[:id]}" + c.params.to_s }
  
  # GET /tabs
  # GET /tabs.xml
  def index
    @d = D.find(params[:d])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tabs }
    end
  end

  # GET /tabs/1
  # GET /tabs/1.xml
  def show
    begin
      @tab = nil

      if params[:id]
        # loop all the tab datasource and find the first one has the specific slug
        tab_ds = D.where(:ds_type => "Tab")
        tab_ds.each do |d|
          @tab = d.get_klass.find(:first, :conditions => {:slug => params[:id]}) || d.get_klass.find(params[:id])
          if @tab
          break
          end
        end
      end

      # get the first tab datasource's root
      unless @tab
        @tab = D.where(:ds_type => "Tab").first.get_klass.root
      end

      if @tab
        @page = @tab.page

        if @page
          begin
            template_content = IO.read(File.join(theme_path, "theme", @page.theme_path ))
          rescue
            template_content = IO.read(File.join(theme_path, "theme", "page_default.html" ))
          end
          template = Liquid::Template.parse(template_content)  # Parses and compiles the template
          #TODO need to cache the template somewhere in future

          #Assemble the variable and it's content, and then pass to template
          render_params = Hash.new

          #add the parameters to the template
          param_hash = params
          # unless @tab.param_string.blank?
          #   @tab.param_string.split('&').each do |p_str|
          #     pair = p_str.strip.split('=')
          #     param_hash[pair.first] = pair.last
          #   end
          # end
          render_params["params"] = param_hash
          #add the tabs to the template
          # tabs = Array.new
          # Tab.traverse(:depth_first) do |tab|
          #   tabs << tab
          # end
          # render_params["tabs"] = tabs
          render_params["current_tab"] = @tab

          # Query the datasource based on the parameters
          q = {}
          if param_hash
            param_hash.each do |k,v|
              s = k.split(".")
              if s && s.size > 2 && s[0] == "ds"
                q[s[1]] = {s[2] => v}
              end
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
                render_params[d_key] = r_page_d.default_query.where(q[d_key]).paginate(:page => params[:page], :per_page => @page.per_page || 20)
              end

            end
          end

          respond_to do |format|
            format.html { render :layout => "front", :text => template.render(render_params, :registers => {:controller => self})}
            format.xml  { render :xml => @page }
          end
        else
          render :text => "no page binds to this #{@tab.slug} tab!"
        end
      else
        render :text => "no tab find!"
      end
    rescue BSON::InvalidObjectId => e
      render :text => "page not found" + e.to_s
    end
  end

  # GET /tabs/new
  # GET /tabs/new.xml
  def new
    @d = D.find(params[:d])
    @tab = @d.get_klass.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tab }
    end
  end

  # GET /tabs/1/edit
  def edit
    #@tab = Tab.find(:first, :conditions => {:slug => params[:id]}) || Tab.find(params[:id])
    @d = D.find(params[:d])
    @tab = @d.get_klass.find(params[:id])
  end

  # POST /tabs
  # POST /tabs.xml
  def create
    @d = D.find(params[:d])
    parent_id = params[:tab].delete(:parent_id)
    page_id = params[:tab].delete(:page_id)

    @tab = @d.get_klass.new(params[:tab])

    if page_id && !page_id.blank?
    @page = Page.find(page_id)
    @tab.page = @page
    end

    unless parent_id.blank?
    @tab.parent = @d.get_klass.find(parent_id)
    end

    respond_to do |format|
      if @tab.save
        expire_action_cache(@tab)
        format.html { redirect_to(ds_tabs_path(:d => @d.id), :notice => 'Tab was successfully created.') }
        format.xml  { render :xml => @tab, :status => :created, :location => @tab }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tab.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tabs/1
  # PUT /tabs/1.xml
  def update
    @d = D.find(params[:d])
    parent_id = params[:tab].delete(:parent_id)
    page_id = params[:tab].delete(:page_id)
    @tab = @d.get_klass.find(params[:id])
    unless page_id.blank?
    @page = Page.find(page_id)

    # should be mongoid bug, remove the old page's tab id
    #      if @tab.page
    # old_page_id = @tab.page.id
    # old_page = Page.find(old_page_id)
    # old_page.tabs.delete(@tab)
    # old_page.save
    #      end
    # end
    @tab.page = @page
    end
    unless parent_id.blank?
    @tab.parent = @d.get_klass.find(parent_id)
    end

    respond_to do |format|
      if @tab.update_attributes(params[:tab]) && @tab.save
        expire_action_cache(@tab)
        format.html { redirect_to(ds_tabs_path(:d => @d.id), :notice => 'Tab was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tab.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tabs/1
  # DELETE /tabs/1.xml
  def destroy
    @d = D.find(params[:d])
    @tab = @d.get_klass.find(params[:id])
    @tab.destroy

    respond_to do |format|
      expire_action_cache(@tab)
      format.html { redirect_to(ds_tabs_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end

  def move_up
    @d = D.find(params[:d])
    @tab = @d.get_klass.find(params[:id])
    @tab.move_up

    respond_to do |format|
      expire_action_cache(@tab)
      format.html {redirect_to(ds_tabs_path(:d => @d.id))}
      format.xml  { head :ok }
    end
  end

  def move_down
    @d = D.find(params[:d])
    @tab = @d.get_klass.find(params[:id])

    @tab.move_down

    respond_to do |format|
      expire_action_cache(@tab)
      format.html { redirect_to(ds_tabs_path(:d => @d.id))}
      format.xml  { head :ok }
    end
  end
end
