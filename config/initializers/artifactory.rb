Artifactory.configure do |config|
  config.endpoint = 'https://artifactory.dev.pardot.com/artifactory'
  config.username = ENV['ARTIFACTORY_USERNAME']
  config.password = ENV['ARTIFACTORY_API_KEY']
  config.ssl_verify = true

  # Temporary while we debug comm issues with Artifactory
  if Rails.env.production?
    config.proxy_address = 'proxy'
    config.proxy_port = 3128
  end
end
