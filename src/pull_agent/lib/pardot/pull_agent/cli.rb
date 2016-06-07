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
          raise ArgumentError, usage
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
            raise ArgumentError, usage
          end
        rescue Environments::NoSuchEnvironment
          Logger.log(:crit, "Invalid environment specified: #{env}")
          raise ArgumentError, usage
        end
      end

      def checkin_chef
        response = Canoe.latest_chef_deploy

        if response.deploy?
          deploy = ChefDeployment.new(response.deploy)
          deploy.apply
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
        case request.action
        when "restart"
          Logger.log(:info, "Executing restart tasks")
          environment.conductor.restart!(request)
          Canoe.notify_server(environment, request)
        when "deploy"
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
