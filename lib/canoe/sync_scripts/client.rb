require "pathname"

module Canoe
  module SyncScripts
    class Client
      # path: directory where sync_scripts are located
      def initialize(path, environment)
        @path = path
        @environment = environment
      end

      def deploy(repo_name:, what:, what_details:, user:, deploy_id:, servers:, log_path:, sha:, artifact_url: nil)
        args  = [repo_name]
        args << "commit=#{sha}"
        args << "--artifact-url=#{artifact_url}" unless artifact_url.nil?
        args << "--user=#{user.email}"
        args << "--deploy-id=#{deploy_id}"
        args << "--servers=#{servers.join(",")}" unless servers.empty?
        args << "--no-confirmations"
        args << "--html-color"

        background_shipit(args, [:out, :err] => [log_path, "w"])
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
          fork do
            Process.setsid
            exec(*full_cmd, options.merge(chdir: @path))
          end
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
