module CarrierWave
  module RMagick
    def quality(percentage)
      manipulate! do |img|
        img.write(current_path){ self.quality = percentage } unless img.quality == percentage
        img = yield(img) if block_given?
        img
      end
    end

  end
end

# CarrierWave.configure do |config|
#   config.grid_fs_database = Mongoid.database.name
#   config.grid_fs_host = Mongoid.database.connection.primary_pool.host
#   config.grid_fs_access_url = "/gridfs"
# end