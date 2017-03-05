# attempt to load env files out of the user dir
%w[development production test].each do |env|
  found_env = false

  env_filename = File.expand_path("~/.envvars_canoe_#{env}")
  if File.exist?(env_filename)
    load(env_filename)
    found_env = true
  end

  # load local env files, note this will step on anything in user dir
  env_filename = File.expand_path(File.join(File.dirname(__FILE__), "..", ".envvars_#{env}.rb").to_s)
  if File.exist?(env_filename)
    load(env_filename)
    found_env = true
  end

  break if found_env
end
