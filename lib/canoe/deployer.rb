module Canoe
  class Deployer
    # strategy: The deployment strategy. In production,
    # `Strategies::SyncScripts` is used. In test, `Strategies::Test` is used.
    def initialize(strategy:)
      @strategy = strategy
    end

    def deploy(target:, user:, repo:, what:, what_details:, sha:, passed_ci:, build_number: nil, artifact_url: nil, lock: false, server_hostnames: nil)
      # Differentiate between servers which use sync_scripts and those that use
      # pull_agent
      if target.script_path.nil?
        sync_servers = []
      else
        sync_servers = @strategy.list_servers(target, repo.name)
      end
      if server_hostnames
        sync_servers = sync_servers & server_hostnames
      end

      pull_servers = target.servers(repo: repo).enabled
      if server_hostnames
        pull_servers = pull_servers.where(hostname: server_hostnames)
      end

      # REFACTOR: An exception might be more appropriate -@alindeman
      # Last guard against a duplicate deploy
      return nil if target.active_deploy(repo).present?

      deploy = target.transaction do
        target.deploys.create!(
          auth_user: user,
          repo_name: repo.name,
          what: what,
          what_details: what_details,
          completed: false,
          specified_servers: (server_hostnames && server_hostnames.join(",")).presence,
          servers_used: sync_servers.join(","),
          sha: sha,
          passed_ci: passed_ci,
          build_number: build_number,
          artifact_url: artifact_url,
        ).tap { |deploy|
          DeployWorkflow.initiate(deploy: deploy, servers: pull_servers)
        }
      end

      target.lock!(repo, user) if lock

      if !target.script_path.nil? && !sync_servers.empty?
        if pid = @strategy.perform(deploy)
          Process.detach(pid)
          deploy.update_attribute(:process_id, pid)
        end
      end

      deploy
    end
  end
end
