rails_env = ENV.fetch("RAILS_ENV", "development")
env_file = File.expand_path("../../.envvars_#{rails_env}.rb", __FILE__)
if File.exist?(env_file)
  load env_file
end

# Set up gems listed in the Gemfile.
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
