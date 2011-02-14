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
        ds = @page.ds
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
          
        if ds
          for d in ds
            if q[d.key].nil?
              render_params[d.key] = d.get_klass.all
            else
              render_params[d.key] = d.get_klass.where(q[d.key])
            end
          end
        end

        respond_to do |format|
          format.html { render :layout => "front", :text => template.send(:render, render_params)}
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
    parent_id = params[:tab].delete(:parent)
    @tab = Tab.new(params[:tab])
    unless params[:tab][:page].blank?
      @page = Page.find(params[:tab][:page])
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
    parent_id = params[:tab].delete(:parent)
    page_id = params[:tab].delete(:page)
    @tab = Tab.find(:first, :conditions => {:slug => params[:id]}) || Tab.find(params[:id])
    unless page_id.blank?
      @page = Page.find(page_id)
    
      # should be mongoid bug, remove the old page's tab id
      if @tab.page
        old_page_id = @tab.page.id
        old_page = Page.find(old_page_id)
        old_page.update_attributes({:tab_id => ""})
      end
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
