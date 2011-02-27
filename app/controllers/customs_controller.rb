class CustomsController < ApplicationController
  before_filter :get_setting

  def index
    @d = D.find(params[:d])
    @records = @d.get_klass.all.desc(:position).paginate(:page => params[:page], :per_page => @setting.per_page || 5)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tabs }
    end
  end

  def edit
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @record }
    end
  end

  def update
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      if @record.update_attributes(params[:record])
        format.html { redirect_to(customs_path(:d => @d.id)) }
        format.xml  { head :ok }
      else
        render_html(@d, format)
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new
    @d = D.find(params[:d])
    @record = @d.get_klass.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @record }
    end
  end

  def create
    @d = D.find(params[:d])
    @record = @d.get_klass.new(params[:record])
    
    respond_to do |format|
      if @record.save
        format.html { redirect_to(customs_path(:d => @d.id))}
        format.xml { head :ok}
      else
        render_html(@d, format)
        format.xml { render :xml => @record.erros, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.destroy

    respond_to do |format|
      format.html { redirect_to(customs_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end
  
  def show
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @record }
    end
  end
  
  def move_up
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.move_up

    respond_to do |format|
      format.html { redirect_to(customs_path(:d => @d.id)) }
      format.xml  { head :ok }
    end    
  end
  
  def move_down
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.move_down

    respond_to do |format|
      format.html { redirect_to(customs_path(:d => @d.id)) }
      format.xml  { head :ok }
    end    
  end
  
end
