module Pardot
  module PullAgent
    class CLI
      attr_reader :environment, :project

      def initialize(args = ARGV)
        @arguments = args
        parse_arguments!
      end

      def checkin
        GlobalConfiguration.load(@environment).merge_into_environment

        ENV["LOG_LEVEL"] = "7"
        Instrumentation.setup("pull-agent", @environment, log_stream: Logger)

        if @project == "chef"
          return checkin_chef
        end

        deploy = Canoe.latest_deploy(@environment, @project)
        Logger.context[:deploy_id] = deploy.id

        if deploy.applies_to_this_server?
          if deploy.action.nil?
            Logger.log(:debug, "Nothing to do for this deploy at this time")
          else
            deployer = DeployerRegistry.fetch(@project).new(@environment, deploy)
            deployer.perform
          end
        else
          Logger.log(:debug, "The deploy does not apply to this server")
        end
      end

      def checkin_chef
        Pardot::PullAgent::Deployers::Chef.new(@environment).perform
      end

      def self.knife(args)
        if args.size < 2
          raise ArgumentError, "Usage: pull-agent-knife <environment> <command...>"
        end

        environment = args.shift
        hostname = ShellHelper.hostname
        datacenter =
          if environment == "dev"
            "local"
          else
            hostname.split("-")[3]
          end

        GlobalConfiguration.load(environment).merge_into_environment

        request = {
          payload: JSON.dump(
            command: args,
            server: {
              datacenter: datacenter,
              environment: environment,
              hostname: hostname
            }
          )
        }

        Canoe.knife(request)
      end

      private

      def parse_arguments!
        # environment and project (repository name) are required
        if @arguments.size != 2
          raise ArgumentError, usage
        else
          @environment, @project = @arguments
        end
      end

      def usage
        readme = File.expand_path("../../../../README.md", __FILE__)
        if File.exist?(readme)
          File.read(readme)
        else
          "Please refer to the README for usage information"
        end
      end
    end
  end
end
