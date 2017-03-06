module PullAgent
  class ProxySelector
    # Sets http_proxy and https_proxy to a random element of the list of possible
    # proxies in http_proxy_list and https_proxy_list, respectively.
    def configure_random_proxy
      %w[http https].each do |type|
        options = ENV.fetch("#{type}_proxy_list", "").split(/\s*,\s*/)
        next if options.empty?

        ENV["#{type}_proxy"] = options.sample
      end
    end
  end
end
