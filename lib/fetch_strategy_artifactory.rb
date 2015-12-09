require "uri"
require "fetch_strategy_base"
require 'artifactory'

class FetchStrategyArtifactory < FetchStrategyBase
  include Artifactory::Resource
  attr_accessor :environment

  def initialize(environment)
    self.environment = environment

    Artifactory.configure do |config|
      config.endpoint = 'https://artifactory.dev.pardot.com/artifactory'
      config.username = environment.artifactory_user
      config.password = environment.artifactory_token
      config.ssl_verify = true

      proxy = URI(config.endpoint).find_proxy
      if proxy
        config.proxy_address = proxy.hostname
        config.proxy_port = proxy.port

        unless environment.staging?
          # If we connect through a proxy, we use an HTTP (non-SSL) URL. The proxy
          # intercepts this request and still talks to the upstream over SSL, but
          # it allows the response to be cached since it's decrypted by the
          # _proxy_ instead of _this host_.
          #
          # Proxies in app.dev are too old to support vhost-based caching. Since
          # app.dev is dying and only has a small number of hosts, we're not
          # going to worry about it there.
          config.endpoint = 'http://artifactory.dev.pardot.com/artifactory'
        end
      end
    end
  end

  def valid?(deploy)
    return false unless deploy.artifact_url
    artifact = Artifact.from_url(deploy.artifact_url)
    artifact && artifact.properties["gitSha"]
  rescue Artifactory::Error::HTTPError
    false
  end

  def fetch(deploy)
    artifact = Artifact.from_url(deploy.artifact_url)
    download_uri = URI.parse(artifact.download_uri)

    FileUtils.mkdir_p(environment.payload.artifacts_path)
    filename = File.join(environment.payload.artifacts_path, File.basename(download_uri.to_s))

    # https://github.com/chef/artifactory-client/blob/0e2fe203608ee3f62fc86c404a590f0cbe6fff30/lib/artifactory/resources/base.rb#L112-L116
    download_path = download_uri.path.sub(/^#{Regexp.escape(URI(Artifactory.client.endpoint).path)}/, "")
    File.open(filename, "wb") do |f|
      f.write(Artifactory.client.get(download_path))
    end

    filename
  end
end
