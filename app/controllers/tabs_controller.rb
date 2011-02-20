class TabsController < ApplicationController
  before_filter :get_setting
  theme :get_theme
  # GET /tabs
  # GET /tabs.xml
  def index
    #@tabs = Tab.roots

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tabs }
    end
  end

  # GET /tabs/1
  # GET /tabs/1.xml
  def show
    begin
      if params[:id]
        @tab = Tab.find(:first, :conditions => {:slug => params[:id]}) || Tab.find(params[:id])
      else
      @tab = Tab.root
      end

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
        unless @tab.param_string.blank?
          @tab.param_string.split('&').each do |p_str|
            pair = p_str.strip.split('=')
            param_hash[pair.first] = pair.last
          end
        end
        render_params["params"] = param_hash
        #add the tabs to the template
        tabs = Array.new
        Tab.traverse(:depth_first) do |tab|
          tabs << tab
        end
        render_params["tabs"] = tabs
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
            if q[r_page_d.d.key].nil?
              render_params[r_page_d.d.key] = r_page_d.default_query.paginate(:page => params[:page], :per_page => @page.per_page || 20)
            else
              render_params[r_page_d.d.key] = r_page_d.default_query.where(q[r_page_d.d.key]).paginate(:page => params[:page], :per_page => @page.per_page || 20)
            end
          end
        end

        respond_to do |format|
          format.html { render :layout => "front", :text => template.render(render_params, :registers => {:controller => self})}
          format.xml  { render :xml => @page }
        end
      else
        redirect_to "http://" + @tab.ref_url
      #TODO actually it is not necessary, should be processed in the browser side
      end
    rescue BSON::InvalidObjectId => e
      render :text => "page not found" + e.to_s
    end
  end

  # GET /tabs/new
  # GET /tabs/new.xml
  def new
    @tab = Tab.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tab }
    end
  end

  # GET /tabs/1/edit
  def edit
    @tab = Tab.find(:first, :conditions => {:slug => params[:id]}) || Tab.find(params[:id])
  end

  # POST /tabs
  # POST /tabs.xml
  def create
    parent_id = params[:tab].delete(:parent_id)
    page_id = params[:tab].delete(:page_id)

    @tab = Tab.new(params[:tab])

    if page_id && !page_id.blank?
    @page = Page.find(page_id)
    @tab.page = @page
    end

    unless parent_id.blank?
    @tab.parent = Tab.find(parent_id)
    end

    respond_to do |format|
      if @tab.save
        #@tab.move_to_bottom
        format.html { redirect_to(tabs_url, :notice => 'Tab was successfully created.') }
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
    parent_id = params[:tab].delete(:parent_id)
    page_id = params[:tab].delete(:page_id)
    @tab = Tab.find(:first, :conditions => {:slug => params[:id]}) || Tab.find(params[:id])
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
    @tab.parent = Tab.find(parent_id)
    end

    respond_to do |format|
      if @tab.save && @tab.update_attributes(params[:tab])
        format.html { redirect_to(@tab, :notice => 'Tab was successfully updated.') }
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
    @tab = Tab.find(:first, :conditions => {:slug => params[:id]}) || Tab.find(params[:id])
    @tab.destroy

    respond_to do |format|
      format.html { redirect_to(tabs_url) }
      format.xml  { head :ok }
    end
  end

  def move_up
    @tab = Tab.find(:first, :conditions => {:slug => params[:id]}) || Tab.find(params[:id])
    @tab.move_up

    respond_to do |format|
      format.html {redirect_to(tabs_url)}
      format.xml  { head :ok }
    end
  end

  def move_down
    @tab = Tab.find(:first, :conditions => {:slug => params[:id]}) || Tab.find(params[:id])
    @tab.move_down

    respond_to do |format|
      format.html { redirect_to(tabs_url)}
      format.xml  { head :ok }
    end
  end
end
