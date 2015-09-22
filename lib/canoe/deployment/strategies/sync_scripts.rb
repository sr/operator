module Canoe
  module Deployment
    module Strategies
      class SyncScripts
        def list_servers(target, repo_name)
          client = build_client(target)
          client.list_servers(repo_name: repo_name)
        end

        def perform(deploy)
          client = build_client(deploy.deploy_target)
          client.deploy(
            repo_name: deploy.repo_name,
            what: deploy.what,
            what_details: deploy.what_details,
            artifact_url: deploy.artifact_url,
            user: deploy.auth_user,
            deploy_id: deploy.id,
            servers: deploy.all_sync_servers,
            log_path: deploy.log_path,
            sha: deploy.sha,
          )
        end

        private
        def build_client(target)
          Canoe::SyncScripts::Client.new(target.script_path, target.name)
        end
      end
    end
  end
end
