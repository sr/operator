module Pardot
  module PullAgent
    module Deployers
      class Pardot
        DeployerRegistry["pardot"] = self

        GRAPHITE_HOST = {
          # pardot0-metrics1-2-dfw.ops.sfdc.net
          "dfw" => "10.247.178.234",
          # pardot0-metrics1-2-phx.ops.sfdc.net
          "phx" => "10.246.178.235"
        }.freeze
        GRAPHITE_PORT = "2003".freeze

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
        end

        def perform_restart
          add_graphite_annotation
          restart_redis_jobs
          restart_old_style_jobs
          restart_autojobs
        end

        def add_graphite_annotation
          host = GRAPHITE_HOST.fetch(ShellHelper.datacenter)

          Timeout.timeout(5) do
            TCPSocket.open(host, GRAPHITE_PORT) do |sock|
              sock.puts("events.deploy.prod 1 #{Time.parse(@deploy.created_at).to_i}")
              sock.close_write
            end
          end
        rescue
          Logger.log(:error, "Unable to connect to graphite: #{$!}")
        end

        def restart_redis_jobs
          Logger.log(:info, "Querying the disco service to find redis job manager masters")

          disco = DiscoveryClient.new
          found = false
          (1..9).each do |i|
            masters = disco.service("redis-job-#{i}").select { |s| s["payload"] && s["payload"]["role"] == "master" }
            masters.each do |master|
              found = true
              Redis.bounce_redis_jobs(master["address"], master["port"])
            end
          end

          unless found
            Logger.log(:warn, "No redis job manager masters were found")
          end
        end

        def restart_old_style_jobs
          cmd = ["#{release_directory.current_symlink}/symfony-#{symfony_env}", "restart-old-jobs"]
          output = ShellHelper.execute(cmd)
          Logger.log(:info, "Restarted old style jobs (#{cmd}): #{output}")
        end

        def restart_autojobs(disco = DiscoveryClient.new, redis = ::Pardot::PullAgent::Redis)
          Logger.log(:info, "Querying the disco service to find redis rule cache masters")

          autojob_disco_master = (1..9).flat_map { |i|
            disco.service("redis-rules-cache-#{i}").select { |s| s["payload"] && s["payload"]["role"] == "master" }
          }.map { |s| [s["address"], s["port"]].join(":") }

          # Restart per account automation workers
          redis.bounce_workers("PerAccountAutomationWorker", autojob_disco_master)
          # Restart timed automation workers
          redis.bounce_workers("PerAccountAutomationWorker-timed", autojob_disco_master)
          # Restart related object workers
          redis.bounce_workers("automationRelatedObjectWorkers", autojob_disco_master)
          # Restart automation preview workers
          redis.bounce_workers("previewWorkers", autojob_disco_master)
        end

        def release_directory
          @release_directory ||=
            ReleaseDirectory.new(ENV.fetch("RELEASE_DIRECTORY", "/var/www/pardot"))
        end

        def symfony_env
          @symfony_env ||=
            if @environment == "production" && ShellHelper.datacenter == "dfw"
              "prod-s"
            elsif @environment == "production"
              "prod"
            elsif @environment == "staging" && ShellHelper.datacenter == "dfw"
              "staging-s"
            elsif @environment == "staging"
              "staging"
            else
              @environment
            end
        end
      end
    end
  end
end
