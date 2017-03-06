require "pathname"
Config = ActiveSupport::OrderedOptions.new
Config.secrets = Rails.application.secrets

Dir[File.join(Rails.application.root, "config", "*.json")].each do |path|
  filename = Pathname.new(path).basename(".*").to_s
  all_configs = JSON.load(File.read(path)) || {}
  next if !all_configs.is_a?(Hash) || filename == "apps"
  Config[filename] = all_configs[Rails.env] || all_configs["production"] || {}
end

