module Pardot
  module PullAgent
    class GlobalConfiguration
      def self.load(environment)
        config_file = ENV["PULL_AGENT_CONFIG_FILE"].to_s
        if !config_file.empty?
          load_from_file(config_file)
        else
          environment_config_file = File.join(File.dirname(__FILE__), "..", "..", "..", ".#{environment}_settings.yml")
          if File.file?(environment_config_file)
            load_from_file(environment_config_file)
          else
            new
          end
        end
      end

      def self.load_from_file(file)
        new(YAML.load(ERB.new(File.read(file))))
      end

      def initialize(options = {})
        @options = options
      end

      def [](option)
        @options[option]
      end

      def merge_into_environment
        [:canoe_api_token, :canoe_url, :artifactory_token].each do |option|
          ENV[option.to_s.upcase] = self[option] if self[option]
        end
      end
    end
  end
end
