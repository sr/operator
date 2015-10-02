class BuildsController < ApplicationController
  before_filter :require_repo

  def create
    if current_repo.bamboo_project.empty? || current_repo.bamboo_plan.empty?
      render status: 422, json: {error: "Bamboo build project and plan not defined for repo"}
    else
      begin
        client = Bamboo::Client.new

        plan_branch = client.plan_branch(project_key: current_repo.bamboo_project, build_key: current_repo.bamboo_plan, branch: params[:branch_name])
        if plan_branch.nil?
          plan_branch = client.create_plan_branch(project_key: current_repo.bamboo_project, build_key: current_repo.bamboo_plan, branch: params[:branch_name])

          client.update_plan_branch(
            plan_key: plan_branch[:plan_key],
            branch: params[:branch_name],
            enabled: true,
            clean_up_plan_automatically: true,
          )
        end

        latest_result = client.latest_result(plan_key: plan_branch[:plan_key])
        if latest_result && latest_result[:life_cycle_state] == "inprogress"
          render status: 200, json: latest_result
        else
          queued_build = client.queue_build(plan_key: plan_branch[:plan_key])
          render status: 201, json: queued_build
        end
      rescue => e
        render status: 500, json: {error: e.message}
      end
    end
  end

  def index
    @include_untested_builds = (params[:include_untested_builds] == "1")

    @builds = current_repo.builds(
      branch: params[:branch_name],
      include_untested_builds: @include_untested_builds,
    )
  end

  private
  def current_branch
    @current_branch ||= current_repo.branch(params[:branch_name])
  end
  helper_method :current_branch
end
