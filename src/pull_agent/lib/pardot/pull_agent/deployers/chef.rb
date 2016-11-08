module Pardot
  module PullAgent
    module Deployers
      class Chef
        def initialize(environment)
          @environment = environment
        end

        def perform
          hostname = ShellHelper.hostname
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

          command = [script, "-d", checkout_pathname.to_s, "status"]
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
          result = ChefDeploy.new(script, checkout_pathname, deploy).apply(env, datacenter, hostname)
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

        private

        def checkout_pathname
          @checkout_pathname ||= Pathname.new("/home/chef-workstation/chef")
        end
      end
    end
  end
end
