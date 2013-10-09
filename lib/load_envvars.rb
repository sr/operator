# load_env_vars.rb
env = ENV["RACK_ENV"]
env ||= 'development'
puts "ENV: #{env}"

# attempt to load env files out of the user dir
env_filename = File.expand_path("~/.envvars_canoe_#{env}")
puts "ENV LOAD: #{env_filename}"
if File.exists?(env_filename)
  puts "LOADING...."
  load(env_filename)
end

# load local env files, note this will step on anything in user dir
env_filename = File.expand_path(File.join(ENV["CANOE_DIR"], ".envvars_#{env}.rb"))
puts "ENV LOAD: #{env_filename}"
if File.exists?(env_filename)
  puts "LOADING...."
  load(env_filename)
end
