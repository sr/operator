module Canoe
  module SinatraTweaks
  end
end

module Sinatra
  module GetOrPost
    def get_or_post(path, options={}, &block)
      get( path, options, &block)
      post(path, options, &block)
    end
  end
end
