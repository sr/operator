module Pardot
  module PullAgent
    class PumaService
      def initialize(pid_file)
        @pid_file = pid_file
      end

      def restart
        pid = File.read(pid_file).chomp

        # Killing puma with USR1 performs a rolling restart
        Process.kill("USR1", pid.to_i)
      end
    end
  end
end
