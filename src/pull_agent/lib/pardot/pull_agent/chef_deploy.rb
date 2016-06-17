module Pardot
  module PullAgent
    class ChefDeploy
      Response = Struct.new(:success, :message)

      CHEF_ENVIRONMENT_FILE = {
        "dfw" => "environments/dfw/production.rb",
        "phx" => "environments/phx/production.rb",
        "ue1.aws" => "environments/aws/production.rb"
      }

      def initialize(script, checkout_path, deploy)
        @script = script
        @checkout_path = checkout_path
        @deploy = deploy
      end

      def apply(env)
        hostname = ShellHelper.hostname
        datacenter = hostname.split("-")[3]
        if !datacenter
          return Response.new(false, "Unable to determine datacenter from hostname: #{hostname.inspect}")
        end

        chef_environment_file = CHEF_ENVIRONMENT_FILE[datacenter]
        if !chef_environment_file
          return Response.new(false, "Unable to determine location of chef environment file for datacenter: #{datacenter.inspect}")
        end

        output = ShellHelper.execute([
          env,
          @script,
          "-d", @checkout_path.to_s,
          "-b", @deploy["branch"],
          "-s", @deploy["sha"],
          "-f", chef_environment_file,
          "deploy"
        ])
        if !$?.success?
          return error(output)
        end

        Response.new(true, "")
      rescue Exception
        Logger.log(:err, "Chef Deploy failed: #{$!.class.inspect} - #{$!.message.inspect}\n\n #{$!.backtrace.join("\n")}")
        Response.new(false, "#{$!.class} - #{$!.message}")
      end

      private

      def error(message)
        Response.new(false, message)
      end
    end
  end
end
