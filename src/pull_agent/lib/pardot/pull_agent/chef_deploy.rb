module Pardot
  module PullAgent
    class ChefDeploy
      Response = Struct.new(:success, :message)

      def initialize(script, checkout_path, deploy)
        @script = script
        @checkout_path = checkout_path
        @deploy = deploy
      end

      def apply
        # TODO(sr) Move this to a script and capture both stdin and stdout
        output = ShellHelper.execute([
          @script,
          "-d", @checkout_path.to_s,
          "-b", @deploy["branch"],
          "-s", @deploy["sha"],
          "deploy"
        ])
        if !$?.success?
          return error(output)
        end

        Response.new(true, "")
      rescue Exception
        # TODO(sr) Instrumentation.log_exception($!)
        Response.new(false, "#{$!.class} - #{$!.message}")
      end

      private

      def error(message)
        Response.new(false, message)
      end
    end
  end
end
