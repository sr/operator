require "pathname"

module Canoe
  module SyncScripts
    class Client
      # path: directory where sync_scripts are located
      def initialize(path, environment)
        @path = path
        @environment = environment
      end

      def deploy(what:, what_details:, user:, deploy_id:, servers:, log_path:, sha:, lock: false)
        args  = ["#{what}=#{what_details}"]
        args << "--lock" if lock
        args << "--user=#{user.email}"
        args << "--deploy-id=#{deploy_id}"
        args << "--servers=#{servers.join(",")}"
        args << "--no-confirmations"
        args << "--html-color"

        io = run_shipit(args, out: log_path, err: log_path)
        io.pid
      end

      def lock(user:)
        run_shipit([
          "--only-lock",
          "--no-color",
          "--user=#{user.email}",
        ]).read
      end

      def unlock(user:, force:)
        run_shipit([
          force ? "--force-unlock" : "--unlock",
          "--no-color",
          "--user=#{user.email}",
        ]).read
      end

      def list_servers
        run_shipit(["--list-servers"])
          .read
          .strip
          .split(/\s*,\s*/)
      end

      private
      def run_shipit(args, options = {})
        full_cmd = [shipit_command_path, @environment] + args

        Rails.logger.debug "Executing: #{full_cmd.inspect}"
        IO.popen(full_cmd, options.merge(chdir: @path))
      end

      def shipit_command_path
        Pathname.new(@path).join("ship-it.rb").to_s
      end
    end
  end
end
