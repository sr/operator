module Pardot
  module PullAgent
    module Strategies
      module Fetch
        class Artifactory < Base
          DownloadFailure = Class.new(StandardError)

          include ::Artifactory::Resource
          attr_accessor :environment

          def initialize(environment)
            self.environment = environment

            ::Artifactory.configure do |config|
              config.endpoint = "https://artifactory.dev.pardot.com/artifactory"
              config.username = environment.artifactory_user
              config.password = environment.artifactory_token
              config.ssl_verify = true

              proxy = URI(config.endpoint).find_proxy
              if proxy
                config.proxy_address = proxy.hostname
                config.proxy_port = proxy.port

                if environment.production?
                  # If we connect through a proxy, we use an HTTP (non-SSL) URL. The proxy
                  # intercepts this request and still talks to the upstream over SSL, but
                  # it allows the response to be cached since it's decrypted by the
                  # _proxy_ instead of _this host_.
                  #
                  # Proxies in app.dev are too old to support vhost-based caching. Since
                  # app.dev is dying and only has a small number of hosts, we're not
                  # going to worry about it there.
                  config.endpoint = "http://artifactory.dev.pardot.com/artifactory"
                end
              end
            end
          end

          def valid?(deploy)
            return false unless deploy.artifact_url
            artifact = Artifact.from_url(deploy.artifact_url)
            artifact && artifact.properties["gitSha"]
          rescue ::Artifactory::Error::HTTPError
            false
          end

          def fetch(deploy)
            artifact = Artifact.from_url(deploy.artifact_url)

            # Construct the download URI from the Artifactory endpoint + the path
            # from download_uri
            #
            # We do this partially so that the download_uri can't convince us to
            # make an arbitrary request with our credentials, but also so that we
            # can take advantage of the Squid proxying (described above)
            download_uri = URI.parse(::Artifactory.client.endpoint)
            download_uri.path = URI.parse(artifact.download_uri).path

            FileUtils.mkdir_p(environment.payload.artifacts_path)
            filename = temporary_artifact_path(deploy)

            # We deliberately do not use Artifactory.client.get because it loads the
            # entire download into memory.
            proxy = download_uri.find_proxy
            Net::HTTP.start(download_uri.host, download_uri.port, proxy && proxy.hostname, proxy && proxy.port, use_ssl: (download_uri.scheme == "https")) do |http|
              http.read_timeout = 300

              request = Net::HTTP::Get.new(download_uri.path)
              if ::Artifactory.client.username && ::Artifactory.client.password
                request.basic_auth(::Artifactory.client.username, ::Artifactory.client.password)
              end

              File.open(filename, "wb", 0o0600) do |f|
                http.request(request) do |response|
                  if response.is_a?(Net::HTTPSuccess)
                    response.read_body do |fragment|
                      f.write(fragment)
                    end
                  else
                    raise DownloadError, "Unable to download artifact: #{response}"
                  end
                end
              end
            end

            filename
          end

          def cleanup(deploy)
            FileUtils.rm_f(temporary_artifact_path(deploy))
          end

          private

          def temporary_artifact_path(deploy)
            File.join(environment.payload.artifacts_path, File.basename(deploy.artifact_url))
          end
        end
      end

      register(:fetch, :artifactory, Fetch::Artifactory)
    end
  end
end
