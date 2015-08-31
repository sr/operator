module Canoe
  class Deployer
    # strategy: The deployment strategy. In production,
    # `Strategies::SyncScripts` is used. In test, `Strategies::Test` is used.
    def initialize(strategy:)
      @strategy = strategy
    end

    def deploy(target:, user:, repo:, what:, what_details:, sha:, build_number: nil, artifact_url: nil, lock: false, servers: nil)
      servers_used = servers || @strategy.list_servers(target, repo.name)

      # REFACTOR: An exception might be more appropriate -@alindeman
      # Last guard against a duplicate deploy
      return nil if target.active_deploy.present?

      deploy = target.deploys.create!(
        auth_user: user,
        repo_name: repo.name,
        what: what,
        what_details: what_details,
        completed: false,
        specified_servers: (servers && servers.join(",")).presence,
        server_count: servers_used.length,
        servers_used: servers_used.join(","),
        sha: sha,
        build_number: build_number,
        artifact_url: artifact_url,
      )

      target.lock!(user) if lock

      # TODO: Remove when artifactory is the only method of deployment.
      unless repo.deploys_via_artifacts?
        if pid = @strategy.perform(deploy, lock: lock)
          Process.detach(pid)
          deploy.update_attribute(:process_id, pid)
        end
      end

      deploy
    end

    def lock(target:, user:)
      target.lock!(user)
      @strategy.lock(target: target, user: user)
    end

    def unlock(target:, user:, force: false)
      target.unlock!(user, force)
      @strategy.unlock(target: target, user: user, force: force)
    end
  end
end
