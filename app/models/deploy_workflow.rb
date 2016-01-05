class DeployWorkflow
  TransitionError = Class.new(StandardError)

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
    result = require_result_for(server: server)
    case [result.stage, action]
    when ["initiated", "deploy"]
      notify_action_deploy_successful(result: result)
    when ["deployed", "restart"]
      notify_action_restart_successful(result: result)
    else
      raise TransitionError, "No transition from #{result.stage} via action #{action} for server #{server.hostname}"
    end
  end

  # Moves any servers still deploying code to the "failed" stage so the restart
  # phase can complete immediately.
  def fail_deploy_on_initiated_servers
    @deploy.results.initiated.update_all(stage: "failed")
    @deploy.check_completed_status!
  end

  # Moves any incomplete server to the "failed" stage. The restart phase, if it
  # hasn't run already, will be skipped.
  def fail_deploy_on_incomplete_servers
    @deploy.results.incomplete.update_all(stage: "failed")
    @deploy.check_completed_status!
  end

  def next_action_for(server:, result: nil)
    return nil if @deploy.completed?

    result ||= require_result_for(server: server)
    if result.initiated?
      "deploy"
    elsif @deploy.restart_server == server && @deploy.results.initiated.empty?
      "restart"
    else
      nil
    end
  end

  private
  def require_result_for(server:)
    @deploy.results.for_server(server).tap do |result|
      raise ArgumentError, "No deploy result found for #{server} in #{deploy}" unless result
    end
  end

  def notify_action_deploy_successful(result:)
    # This update_all line is atomic. It can't race with another restart server
    # being assigned. As far as I know, this is the only way to achieve this
    # kind of thing in Rails :/
    if Deploy.where(id: @deploy.id, restart_server_id: nil).update_all(restart_server_id: result.server_id) > 0
      @deploy.reload
      result.update(stage: "deployed")
    else
      result.update(stage: "completed")
    end

    @deploy.check_completed_status!
  end

  def notify_action_restart_successful(result:)
    result.update(stage: "completed")
    @deploy.check_completed_status!
  end
end
