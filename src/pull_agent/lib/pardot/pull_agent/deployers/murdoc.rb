module Pardot
  module PullAgent
    module Deployers
      class Murdoc
        DeployerRegistry["murdoc"] = self

        def initialize(environment, deploy)
          @environment = environment
          @deploy = deploy
        end

        def perform
          case @deploy.action
          when "deploy"
            perform_deploy
          when "restart"
            perform_restart
          else
            raise DeploymentError, "unknown action: #{@deploy.action}"
          end

          Canoe.notify_server(@environment, @deploy)
        end

        private

        def perform_deploy
          quick_rollback = QuickRollback.new(release_directory, @deploy)
          unless quick_rollback.perform_if_applicable
            Dir.mktmpdir do |temp_dir|
              ArtifactFetcher.new(@deploy.artifact_url).fetch_into(temp_dir)
              DirectorySynchronizer.new(temp_dir, release_directory.standby_directory).synchronize

              @deploy.to_build_version.save_to_directory(release_directory.standby_directory)
              release_directory.make_standby_directory_live
            end
          end

          if @deploy.options["topology"].nil?
            Logger.log(:err, "deploy[topology] not present, can't restart topology")
          elsif @deploy.options["topo_env"].nil?
            Logger.log(:err, "deploy[topo_env] not present, can't restart topology")
          else
            jarfile = Dir[File.join(release_directory.current_symlink, "*.jar")].first
            if jarfile.nil?
              Logger.log(:err, "no *.jar file found in deployment, can't load topology")
            else
              Logger.log(:info, "Topology Deployment Param: #{@deploy.options["topology"]}")
              Logger.log(:info, "Topology Deployment JAR: #{jarfile}")
              storm = Storm.new(@deploy.options["topology"], @deploy.options["topo_env"], jarfile)
              storm.load
            end
          end
        end

        def perform_restart
        end

        def release_directory
          @release_directory ||=
            ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/opt/blue-mesh"))
        end
      end
    end
  end
end
