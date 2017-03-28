module PullAgent
  class TopologyDeploy
    def initialize(deploy, release_directory)
      @deploy = deploy
      @release_directory = release_directory
    end

    def deploy
      current_deploy = BuildVersion.load_from_directory(@release_directory.current_symlink)
      if current_deploy && current_deploy.instance_of_deploy?(@deploy)
        Logger.log(:info, "Requested deploy is already present in #{@release_directory.current_symlink}. Skipping fetch step.")
      else
        quick_rollback = QuickRollback.new(@release_directory, @deploy)
        unless quick_rollback.perform
          Dir.mktmpdir do |temp_dir|
            ArtifactFetcher.new(@deploy.artifact_url).fetch_into(temp_dir)
            DirectorySynchronizer.new(temp_dir, @release_directory.standby_directory).synchronize

            @deploy.to_build_version.save_to_directory(@release_directory.standby_directory)
            @release_directory.make_standby_directory_live
          end
        end
      end

      if @deploy.options["topology"].nil?
        Logger.log(:err, "deploy[topology] not present, can't restart topology")
      elsif @deploy.options["topo_env"].nil?
        Logger.log(:err, "deploy[topo_env] not present, can't restart topology")
      else
        jarfile = Dir[File.join(@release_directory.current_symlink, "*.jar")].first
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
  end
end
