module Pardot
  module PullAgent
    class ChefDeploy
      Response = Struct.new(:success, :message)

      CHEF_ENVIRONMENT_FILE = {
        "dfw" => "environments/dfw/production.rb",
        "phx" => "environments/phx/production.rb",
        "ue1.aws" => "environments/aws/production.rb",
        "dev" => "environments/dev.rb"
      }

      def initialize(script, checkout_path, deploy)
        @script = script
        @checkout_path = checkout_path
        @deploy = deploy
      end

      def apply(env, datacenter, hostname)
        chef_environment_file = CHEF_ENVIRONMENT_FILE[datacenter]
        if !chef_environment_file
          return Response.new(false, "Unable to determine location of chef environment file for datacenter: #{datacenter.inspect}")
        end

        command = [
          @script,
          "-d", @checkout_path.to_s,
          "-b", @deploy["branch"],
          "-s", @deploy["sha"],
          "-f", chef_environment_file,
          "deploy"
        ]
        Instrumentation.debug(at: "chef-deploy", hostname: hostname,
          datacenter: datacenter, command: command)

        output = ShellHelper.execute([env] + command)
        if !$?.success?
          return error(output)
        end

        Response.new(true, "")
      rescue Exception
        Instrumentation.log_exception($!, at: "chef-deploy")
        Response.new(false, "#{$!.class} - #{$!.message}")
      end

      private

      def error(message)
        Response.new(false, message)
      end
    end
  end
end
