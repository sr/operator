module Pardot
  module PullAgent
    class PumaService
      def initialize(pid_file)
        @pid_file = pid_file
      end

      def restart
        pid = File.read(pid_file).chomp

        # Killing puma with USR1 performs a rolling restart
        output = ShellHelper.execute(["kill", "-USR1", pid])
        if $?.success?
          Logger.log(:info, "restarted puma service: #{output}")
          true
        else
          raise DeploymentError, "error restarting puma service: #{output}"
        end
      end
    end
  end
end
