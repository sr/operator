module Canoe
  class Deployer
    def deploy(target:, user:, project:, what:, what_details:, sha:, passed_ci:, build_number: nil, artifact_url: nil, lock: false, server_hostnames: nil, options_validator: nil, options: {})
      servers = target.servers(project: project).enabled
      if server_hostnames
        servers = servers.where(hostname: server_hostnames)
      end

      # REFACTOR: An exception might be more appropriate -@alindeman
      # Last guard against a duplicate deploy
      return nil if target.active_deploy(project).present?

      deploy = target.transaction do
        new_deploy = target.deploys.create!(
          auth_user: user,
          project_name: project.name,
          what: what,
          what_details: what_details,
          completed: false,
          sha: sha,
          passed_ci: passed_ci,
          build_number: build_number,
          artifact_url: artifact_url,
          options_validator: options_validator,
          options: options,
        )
        DeployWorkflow.initiate(deploy: new_deploy, servers: servers)
        new_deploy
      end

      target.lock!(project, user) if lock

      deploy
    end
  end
end
