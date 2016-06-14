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
        Logger.log(:err, "Chef Deploy failed: #{$!.class.inspect} - #{$!.message.inspect}")
        Response.new(false, "#{$!.class} - #{$!.message}")
      end

      private

      def error(message)
        Response.new(false, message)
      end
    end
  end
end
