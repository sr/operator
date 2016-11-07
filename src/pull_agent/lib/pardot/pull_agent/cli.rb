module Pardot
  module PullAgent
    class CLI
      attr_reader :environment, :project

      def initialize(args = ARGV)
        @arguments = args
        parse_arguments!

        GlobalConfiguration.load(@environment).merge_into_environment
      end

      def checkin
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
        ENV["LOG_LEVEL"] = "7"
        Instrumentation.setup("pull-agent", @environment, log_stream: Logger)

        hostname = ShellHelper.hostname
        repo_path = Pathname(payload.repo_path)
        script = File.expand_path("../../../../bin/pa-deploy-chef", __FILE__)

        datacenter =
          if @environment
            "local"
          else
            hostname.split("-")[3]
          end

        if !datacenter
          Instrumentation.error(at: "chef", hostname: hostname)
          return
        end

        env = {
          "PATH" => "#{File.dirname(RbConfig.ruby)}:#{ENV.fetch("PATH")}"
        }

        command = [script, "-d", repo_path.to_s, "status"]
        output = ShellHelper.execute([env] + command)

        if !$?.success?
          Instrumentation.error(
            at: "chef",
            command: command,
            output: output
          )
          return
        end

        payload = {
          server: {
            datacenter: datacenter,
            environment: @environment,
            hostname: hostname
          },
          checkout: JSON.parse(output)
        }

        request = { payload: JSON.dump(payload) }
        response = Canoe.chef_checkin(@environment, request)

        if response.code != "200"
          Instrumentation.error(
            at: "chef",
            code: response.code,
            body: response.body[0..100]
          )
          return
        end

        payload = JSON.parse(response.body)

        if payload.fetch("action") != "deploy"
          Instrumentation.debug(at: "chef", action: "noop")
          return
        end

        deploy = payload.fetch("deploy")
        result = ChefDeploy.new(script, repo_path, deploy).apply(env, datacenter, hostname)
        payload = {
          deploy_id: deploy.fetch("id"),
          success: result.success,
          error_message: result.message
        }
        request = { payload: JSON.dump(payload) }

        Instrumentation.debug(at: "chef", completed: payload)
        response = Canoe.complete_chef_deploy(@environment, request)

        if response.code != "200"
          Instrumentation.error(
            at: "chef",
            complete: "error",
            code: response.code,
            body: response.body[0..100]
          )
        end
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

        request = {
          payload: JSON.dump(
            command: args,
            server: {
              datacenter: datacenter,
              environment: environment.name,
              hostname: hostname
            }
          )
        }

        Canoe.knife(environment, request)
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
