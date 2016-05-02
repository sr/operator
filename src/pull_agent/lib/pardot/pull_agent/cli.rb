module Pardot
  module PullAgent
    class CLI
      attr_reader :environment

      def initialize(args = ARGV)
        @arguments = args
      end

      def parse_arguments!
        # environment and payload (repository name) are required
        if @arguments.size != 2
          fail ArgumentError, print_help
        else
          env, payload = @arguments
        end

        begin
          @environment = Environments.build(env.downcase)
          if @environment.valid_payload?(payload)
            @environment.payload = payload
            Logger.context[:payload] = payload
          else
            Logger.log(:crit, "Invalid payload specified: #{payload}")
            fail ArgumentError, print_help
          end
        rescue Environments::NoSuchEnvironment
          Logger.log(:crit, "Invalid environment specified: #{env}")
          raise ArgumentError, print_help
        end
      end

      def checkin
        request = Canoe.latest_deploy(environment)
        Logger.context[:deploy_id] = request.id

        if request.applies_to_this_server?
          client_action(request)
        else
          Logger.log(:debug, "The deploy does not apply to this server")
        end
      end

      private

      def client_action(request)
        if request.action == "restart"
          Logger.log(:info, "Executing restart tasks")
          environment.conductor.restart!(request)
          Canoe.notify_server(environment, request)
        elsif request.action == "deploy"
          deploy_action(request)
        else
          Logger.log(:debug, "Nothing to do for this deploy")
        end
      end

      def deploy_action(request)
        current_build_version = BuildVersion.load(environment.payload.build_version_file)
        if current_build_version && current_build_version.instance_of_deploy?(request) && !environment.bypass_version_detection?
          Logger.log(:info, "We are up to date")
          Canoe.notify_server(environment, request)
        else
          Logger.log(:info, "Currently deploy: #{current_build_version && current_build_version.artifact_url || '<< None >>'}")
          Logger.log(:info, "Requested deploy: #{request.artifact_url}")
          environment.conductor.deploy!(request)
        end
      end

      def print_help
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
