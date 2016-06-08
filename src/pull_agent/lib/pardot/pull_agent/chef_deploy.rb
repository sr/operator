module Pardot
  module PullAgent
    class ChefDeploy
      Response = Struct.new(:success, :message)

      def initialize(deploy)
        @deploy = deploy
      end

      def apply(env)
        # TODO(sr) Move this to a script and capture both stdin and stdout
        output = ShellHelper.execute([env, "git", "checkout", @deploy["branch"]])
        if !$?.success?
          return error("unable to checkout branch #{@deploy["branch"]}: #{output.inspect}")
        end

        output = ShellHelper.execute([env, "git", "reset", "--hard", @deploy["sha"]])
        if !$?.success?
          return error("unable to checkout SHA1 #{@deploy["sha"]}: #{output.inspect}")
        end

        output = ShellHelper.execute([env, "echo", "knife-sync"])
        if !$?.success?
          return error("unable to run knife: #{output.inspect}")
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

      def directory
      end
    end
  end
end
