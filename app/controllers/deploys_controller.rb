class DeploysController < ApplicationController
  before_filter :require_repo

  def select_target
    @prov_deploy = provisional_deploy
    @targets = DeployTarget.order(:name)
  end
end
