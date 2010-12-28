
config_file = "#{RAILS_ROOT}/config/database.yml"

if File.exist? config_file
  config = YAML.load(File.read(config_file))[RAILS_ENV]
  if config && config["adapter"] == "mongodb"
    MongoMapper.connection = Mongo::Connection.new(config["server"], config["port"] || 27017)
    MongoMapper.database = config["database"]
    
    if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
        MongoMapper.connection.connect_to_master if forked
      end
    end
  end
end

