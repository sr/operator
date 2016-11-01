module Canoe
  class Deployer
    def deploy(target:, user:, project:, branch:, sha:, passed_ci:, build_number: nil, artifact_url: nil, lock: false, server_hostnames: nil, options_validator: nil, options: {})
      if server_hostnames && !server_hostnames.empty?
        servers = target.servers(project: project).enabled.where(hostname: server_hostnames)
      elsif project.all_servers_default
        servers = target.servers(project: project).enabled
      else
        servers = []
      end

      # REFACTOR: An exception might be more appropriate -@alindeman
      # Last guard against a duplicate deploy
      return nil if target.active_deploy(project).present?

      deploy = target.transaction do
        new_deploy = target.deploys.create!(
          auth_user: user,
          project_name: project.name,
          branch: branch,
          completed: false,
          sha: sha,
          passed_ci: passed_ci,
          build_number: build_number,
          artifact_url: artifact_url,
          options_validator: options_validator,
          options: options,
        )
        DeployWorkflow.initiate(
          deploy: new_deploy,
          servers: servers,
          maximum_unavailable_percentage_per_datacenter: project.maximum_unavailable_percentage_per_datacenter,
        )
        new_deploy
      end

      target.lock!(project, user) if lock

      deploy
    end
  end
end
