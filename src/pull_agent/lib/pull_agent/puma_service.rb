module PullAgent
  class PumaService
    def initialize(pid_file)
      @pid_file = pid_file
    end

    def restart
      pid = File.read(pid_file).chomp.to_i
      return false unless pid > 1

      # Killing puma with USR1 performs a rolling restart
      Process.kill("USR1", pid)
    end
  end
end
