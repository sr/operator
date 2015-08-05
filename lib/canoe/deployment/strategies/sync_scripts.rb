module Canoe
  module Deployment
    module Strategies
      class SyncScripts
        def list_servers(target)
          client = build_client(target)
          client.list_servers
        end

        def perform(deploy, lock: false)
          client = build_client(deploy.target)
          client.deploy(
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

        private
        def build_client(target)
          SyncScripts::Client.new(deploy.target.script_path, target.name)
        end
      end
    end
  end
end
