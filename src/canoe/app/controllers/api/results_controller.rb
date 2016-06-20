module Api
  class ResultsController < Controller
    before_filter :require_target
    before_filter :require_deploy
    before_filter :require_result

    def update
      workflow = DeployWorkflow.new(deploy: current_deploy)
      if params[:success].to_s == "true"
        workflow.notify_action_successful(server: current_result.server, action: request.request_parameters[:action])
        render status: 303, nothing: true, location: api_target_deploy_url(current_target, current_deploy)
      else
        render status: 500, json: { error: "not implemented" }
      end
    rescue DeployWorkflow::TransitionError => e
      render status: 400, json: { error: e.message }
    end
  end
end
