require "net/http"
require "uri"

module PullAgent
  # ArtifactFetcher fetches tarballs from Artifactory and uncompresses them
  class ArtifactFetcher
    FetchError = Class.new(StandardError)
    DecompressionError = Class.new(StandardError)

    def initialize(artifact_url)
      @artifact_url = URI(artifact_url)
      @artifact_url.host = artifactory_host

      @proxy = @artifact_url.find_proxy
      if @proxy
        # If we connect through a proxy, we use an HTTP (non-SSL) URL. The proxy
        # intercepts this request and still talks to the upstream over SSL, but
        # it allows the response to be cached since it's decrypted by the
        # _proxy_ instead of _this host_.
        @artifact_url.scheme = "http"
      else
        @artifact_url.scheme = "https"
      end
    end

    # Fetches a deployment artifact and uncompresses it into a directory
    # (which must already exist).
    def fetch_into(directory)
      Logger.log(:debug, "Fetching #{@artifact_url} to #{directory}")
      object = with_http_client do |http|
        request = Net::HTTP::Get.new(@artifact_url.path)
        request.basic_auth(artifactory_user, artifactory_token)

        response = http.request(request)
        response.value # raise error if non-successful

        JSON.parse(response.body)
      end

      download_path = URI(object.fetch("downloadUri")).path

      with_http_client do |http|
        request = Net::HTTP::Get.new(download_path)
        request.basic_auth(artifactory_user, artifactory_token)

        http.request(request) do |response|
          response.value # raise error if non-successful

          output = IO.popen(["tar", "-xzf", "-", "-C", directory], "r+", err: [:child, :out]) { |io|
            response.read_body do |chunk|
              io.write(chunk)
            end
            io.close_write
            io.read
          }
          raise DecompressionError, "Unable to uncompress artifact: #{output}" unless $?.success?
        end
      end
    end

    private

    def with_http_client
      Net::HTTP.start(
        @artifact_url.host,
        @artifact_url.scheme == "https" ? 443 : 80,
        (@proxy && @proxy.hostname),
        (@proxy && @proxy.port),
        use_ssl: (@artifact_url.scheme == "https"),
        &Proc.new
      )
    end

    def artifactory_host
      ENV.fetch("ARTIFACTORY_HOST", "artifactory.dev.pardot.com")
    end

    def artifactory_user
      ENV.fetch("ARTIFACTORY_USER")
    end

    def artifactory_token
      ENV.fetch("ARTIFACTORY_TOKEN")
    end
  end
end
