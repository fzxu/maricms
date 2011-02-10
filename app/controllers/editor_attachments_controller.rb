class EditorAttachmentsController < ApplicationController
  protect_from_forgery :except => :upload  

  def upload  
    @image = EditorAttachment.new(:asset => params[:imgFile])  
    if @image.save  
      render :text => {"error" => 0, "url" => @image.asset.url}.to_json  
    else  
      render  :text => {"error" => 1}  
    end  
  end  

  def images_list 
    @images=EditorAttachment.asc(order_param)
    @json = []  
    for image in @images  
      temp =  %Q/{"filesize" : #{image.asset.size},  
      "filename" : "#{image.asset_file_name}",  
      "url" : "#{image.asset.url}",
      "icon" : "#{image.asset.url(:icon)}",
      "is_photo" : true,  
      "datetime" : "#{image.created_at.to_s(:short)}"}/  
      @json << temp     
    end     
    render :text => ("{\"file_list\":[" << @json.join(", ") << "]}")  
  end
  
  private
  
  def order_param
    params[:order] || "asset_file_name"
  end 
end
