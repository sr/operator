class DeployWorkflow
  def self.initiate(deploy:, servers:)
    servers.each do |server|
      deploy.results.create!(server: server, stage: "initiated")
    end

    new(deploy: deploy)
  end

  def initialize(deploy: deploy)
    @deploy = deploy
  end

  def notify_action_successful(server:, action:)
    result = @deploy.results.for_server(server)
    raise ArgumentError, "No deploy result found for #{server} in #{deploy}" unless result

    # This update_all line is atomic. It can't race with another restart server
    # being assigned. As far as I know, this is the only way to achieve this
    # kind of thing in Rails :/
    if Deploy.where(id: @deploy.id, restart_server_id: nil).update_all(restart_server_id: server.id) > 0
      result.update(stage: "deployed")
    else
      result.update(stage: "completed")
    end
  end
end
