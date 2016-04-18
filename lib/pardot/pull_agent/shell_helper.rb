module Pardot
  module PullAgent
    class ShellHelper
      SecurityException = Class.new(StandardError)

      def self.hostname
        # Let the environment variable override the hostname
        ENV.fetch("PULL_HOSTNAME", Socket.gethostname.sub(/(\.pardot\.com|\.ops\.sfdc\.net|\.pd25\.com|\.pd26\.com)$/, ""))
      end

      # this should make it easier to test, etc...
      def self.execute(command, opt = {})
        raise SecurityException.new("command must be an array to avoid shell expansion") unless command.is_a?(Array)

        IO.popen(command, opt) { |io| io.read.strip }
      end

      def self.sudo_execute(command, user = 'root', opt = {})
        raise SecurityException.new("command must be an array to avoid shell expansion") unless command.is_a?(Array)

        sudo_command = "sudo -u #{user} #{command}"
        execute(["sudo", "-u", user, *command], opt)
      end
    end
  end
end
