class EditorAttachmentsController < ApplicationController
  protect_from_forgery :except => :upload
  before_filter :get_setting

  def upload  
    @image = EditorAttachment.new(:asset => params[:imgFile])  
    if @image.save  
      render :text => {"error" => 0, "url" => @image.asset.url}.to_json  
    else  
      render  :text => {"error" => 1}  
    end  
  end  

  def images_list 
    @images = EditorAttachment.desc(params[:order] || "created_at")
    @json = []  
    for image in @images  
      temp =  %Q/{"filesize" : "#{image.asset_filesize}",
      "filename" : "#{image.asset_filename}",  
      "url" : "#{image.asset.url}",
      "icon" : "#{image.asset.icon.url}",
      "is_photo" : true,  
      "datetime" : "#{image.created_at.strftime(@setting.date_format)}"}/  
      @json << temp     
    end     
    render :text => ("{\"file_list\":[" << @json.join(", ") << "]}")  
  end
  
end
