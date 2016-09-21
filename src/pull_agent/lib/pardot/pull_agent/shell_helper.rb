module Pardot
  module PullAgent
    class ShellHelper
      SecurityException = Class.new(StandardError)

      def self.hostname
        # Let the environment variable override the hostname
        ENV.fetch("PULL_HOSTNAME", Socket.gethostname.sub(/(\.aws\.pardot\.com|\.ops\.sfdc\.net)$/, ""))
      end

      # TODO: Remove this when we have standardized on chef as our ansible dynamic inventory
      def self.datacenter
        hostname.split("-").last
      end

      # this should make it easier to test, etc...
      def self.execute(command, opt = {})
        raise SecurityException, "command must be an array to avoid shell expansion" unless command.is_a?(Array)

        IO.popen(command, opt) { |io| io.read.strip }
      end

      def self.sudo_execute(command, user = "root", opt = {})
        raise SecurityException, "command must be an array to avoid shell expansion" unless command.is_a?(Array)
        execute(["sudo", "-u", user, *command], opt)
      end
    end
  end
end
