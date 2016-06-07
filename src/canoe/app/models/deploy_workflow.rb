class DeployWorkflow
  TransitionError = Class.new(StandardError)

  def self.initiate(deploy:, servers:)
    servers.each do |server|
      deploy.results.create!(server: server, stage: "initiated")
    end
    servers.group_by(&:datacenter).keys.each do |dc|
      deploy.deploy_restart_servers.create!(datacenter: dc)
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

  def pick_new_restart_servers
    @deploy.deploy_restart_servers.each_with_index do |restart, i|
      old_restart_result = @deploy.results.for_server(restart.server)
      unless old_restart_result.completed?
        possible_servers = @deploy.results.completed.map(&:server).shuffle
        unless possible_servers.empty?
          restart_server = possible_servers[possible_servers.index{|s| s.datacenter == restart.server.datacenter}]
          # This could be refactored to use the restart_servers :through association directly,
          # but I can't figure out how to set the datacenter column through ActiveRecord in the relational table
          @deploy.deploy_restart_servers[i].update_attribute(:server_id, restart_server.id)
          @deploy.results.for_server(restart_server).update_attribute(:stage, "deployed")
          old_restart_result.update_attribute(:stage, "completed")
        end
      end
    end
  end

  def next_action_for(server:, result: nil)
    return nil if @deploy.completed?

    result ||= require_result_for(server: server)
    if result.initiated?
      "deploy"
    elsif @deploy.restart_servers.include?(server) && @deploy.results.initiated.empty?
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
    if DeployRestartServer.where(deploy_id: @deploy.id, datacenter: result.server.datacenter, server_id: nil).update_all(server_id: result.server_id) > 0
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
