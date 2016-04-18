module Pardot
  module PullAgent
    module Environments
      NoSuchEnvironment = Class.new(StandardError)

      def self.register(name, klass)
        @environments ||= {}
        @environments[name.to_sym] = klass
      end

      def self.build(name)
        @environments.fetch(name.to_sym).new
      rescue KeyError
        raise NoSuchEnvironment, "No environment with name #{name}"
      end
    end

    require_relative "environments/dev"
    require_relative "environments/test"
    require_relative "environments/staging"
    require_relative "environments/production"
    require_relative "environments/production_dfw"
    require_relative "environments/production_phx"
  end
end
