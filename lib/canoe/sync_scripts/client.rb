require "pathname"

module Canoe
  module SyncScripts
    class Client
      # path: directory where sync_scripts are located
      def initialize(path, environment)
        @path = path
        @environment = environment
      end

      def deploy(repo_name:, what:, what_details:, user:, deploy_id:, servers:, log_path:, sha:, lock: false)
        args  = [repo_name]
        args << "#{what}=#{what_details}"
        args << "--lock" if lock
        args << "--user=#{user.email}"
        args << "--deploy-id=#{deploy_id}"
        args << "--servers=#{servers.join(",")}"
        args << "--no-confirmations"
        args << "--html-color"

        background_shipit(args, [:out, :err] => [log_path, "w"])
      end

      def lock(user:)
        run_shipit([
          "--only-lock",
          "--no-color",
          "--user=#{user.email}",
        ])
      end

      def unlock(user:, force:)
        run_shipit([
          force ? "--force-unlock" : "--unlock",
          "--no-color",
          "--user=#{user.email}",
        ])
      end

      def list_servers(repo_name:)
        run_shipit([repo_name, "--list-servers"])
          .strip
          .split(/\s*,\s*/)
      end

      private

      def run_shipit(args)
        full_cmd = shipit_full_cmd(args)

        Rails.logger.debug "Executing: #{full_cmd.inspect}"
        Bundler.with_clean_env do
          IO.popen(full_cmd, chdir: @path) { |io| io.read }
        end
      end

      def background_shipit(args, options = {})
        full_cmd = shipit_full_cmd(args)

        Rails.logger.debug "Executing: #{full_cmd.inspect}"
        Bundler.with_clean_env do
          spawn(*full_cmd, options.merge(chdir: @path))
        end
      end

      def shipit_full_cmd(args)
        full_cmd = []
        if File.executable?(rbenv_shim_path)
          full_cmd << rbenv_shim_path
        end

        full_cmd << shipit_command_path
        full_cmd << @environment
        full_cmd.concat(args)
        full_cmd
      end

      def shipit_command_path
        Pathname.new(@path).join("ship-it.rb").to_s
      end

      def rbenv_shim_path
        "/opt/rbenv/shims/ruby".freeze
      end
    end
  end
end
