require 'bourbon'
require 'bootstrap-sass'
require 'autoprefixer-rails'

class Purple
  class Railtie < Rails::Railtie
    initializer 'purple' do
      Rails.configuration.assets.paths += [
        File.expand_path('../../sass', __FILE__),
        File.expand_path('../../rails', __FILE__)
      ]
    end
  end
end
