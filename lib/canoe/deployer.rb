module Canoe
  class Deployer
    def deploy(target:, user:, repo:, what:, what_details:, sha:, passed_ci:, build_number: nil, artifact_url: nil, lock: false, server_hostnames: nil)
      servers = target.servers(repo: repo).enabled
      if server_hostnames
        servers = servers.where(hostname: server_hostnames)
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
          sha: sha,
          passed_ci: passed_ci,
          build_number: build_number,
          artifact_url: artifact_url,
        ).tap { |deploy|
          DeployWorkflow.initiate(deploy: deploy, servers: servers)
        }
      end

      target.lock!(repo, user) if lock

      deploy
    end
  end
end
