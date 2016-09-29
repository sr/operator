module Canoe
  module DeployLogic
    def deploy!(prov_deploy)
      request = DeployRequest.new(
        current_project,
        current_target,
        current_user,
        params
      )
      request.deploy!(prov_deploy)
    end
  end
end
