module Canoe
  module EnvTests
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def is_development?
        ENV["RACK_ENV"] == "development"
      end

      def is_app_dev?
        ENV["RACK_ENV"] == "app.dev"
      end

      def is_production?
        ENV["RACK_ENV"] == "production"
      end
    end

  end
end
