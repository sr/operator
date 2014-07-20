module Canoe
  module EnvTests
    def self.is_development?
      ENV["RACK_ENV"] == "development"
    end

    def self.is_app_dev?
      ENV["RACK_ENV"] == "app.dev"
    end

    def self.is_production?
      ENV["RACK_ENV"] == "production"
    end

  end
end
