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

      def checkin
        if environment.payload.id == :chef
          return checkin_chef
        end

        request = Canoe.latest_deploy(environment)
        Logger.context[:deploy_id] = request.id

        if request.applies_to_this_server?
          client_action(request)
        else
          Logger.log(:debug, "The deploy does not apply to this server")
        end
      end

      def checkin_chef
        payload = environment.payload
        repo_path = Pathname(payload.repo_path)
        script = File.expand_path("../../../../bin/pa-deploy-chef", __FILE__)

        env = {
          "PATH" => "#{File.dirname(RbConfig.ruby)}:#{ENV.fetch("PATH")}"
        }
        output = ShellHelper.execute([env, script, "-d", repo_path.to_s, "status"])
        if !$?.success?
          raise "unable to retrieve status of checkout: #{output.inspect}"
        end

        payload = {
          environment: environment.name,
          hostname: ShellHelper.hostname,
          checkout: JSON.parse(output)
        }

        request = { payload: JSON.dump(payload) }
        response = Canoe.chef_checkin(environment, request)

        if response.code != "200"
          raise "Checkin request failed: #{response.code} - #{response.body}"
        end

        payload = JSON.parse(response.body)

        if payload.fetch("action") != "deploy"
          return
        end

        result = ChefDeploy.new(script, repo_path, payload.fetch("deploy")).apply(env)
        payload = {
          hostname: ShellHelper.hostname,
          deploy: payload.fetch("deploy"),
          error: !result.success,
          message: result.message
        }
        request = { payload: JSON.dump(payload) }
        Canoe.complete_chef_deploy(environment, request)
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
