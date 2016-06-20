Artifactory.configure do |config|
  config.endpoint = "https://artifactory.dev.pardot.com/artifactory"
  config.username = ENV["ARTIFACTORY_USERNAME"]
  config.password = ENV["ARTIFACTORY_API_KEY"]
  config.ssl_verify = true
end
