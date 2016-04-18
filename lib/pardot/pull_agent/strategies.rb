module Pardot
  module PullAgent
    module Strategies
      NoSuchStrategy = Class.new(StandardError)

      # action: e.g., "fetch" or "deploy"
      # name: e.g., "artifactory"
      def self.register(action, name, klass)
        @strategies ||= Hash.new { |h, k| h[k] = {} }
        @strategies[action.to_sym][name.to_sym] = klass
      end

      def self.build(action, name, environment)
        @strategies.fetch(action.to_sym).fetch(name.to_sym).new(environment)
      rescue KeyError
        raise NoSuchStrategy, "No strategy with name #{name}"
      end
    end

    require_relative "strategies/fetch/artifactory"
    require_relative "strategies/deploy/atomic"
  end
end
