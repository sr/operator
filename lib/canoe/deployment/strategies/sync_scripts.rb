module Canoe
  module Deployment
    module Strategies
      class SyncScripts
        def list_servers(target, repo_name)
          client = build_client(target)
          client.list_servers(repo_name: repo_name)
        end

        def perform(deploy, lock: false)
          client = build_client(deploy.deploy_target)
          client.deploy(
            repo_name: deploy.repo_name,
            what: deploy.what,
            what_details: deploy.what_details,
            user: deploy.auth_user,
            deploy_id: deploy.id,
            servers: deploy.all_servers,
            log_path: deploy.log_path,
            sha: deploy.sha,
            lock: lock,
          )
        end

        def lock(target:, user:)
          client = build_client(target)
          client.lock(user: user)
        end

        def unlock(target:, user:, force:)
          client = build_client(target)
          client.unlock(user: user, force: force)
        end

        private
        def build_client(target)
          Canoe::SyncScripts::Client.new(target.script_path, target.name)
        end
      end
    end
  end
end
