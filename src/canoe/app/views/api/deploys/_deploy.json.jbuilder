json.id deploy.id
json.target deploy.deploy_target.name
json.user deploy.auth_user.email
json.project deploy.project_name
json.branch deploy.branch
json.options deploy.options || {}
json.build_number deploy.build_number
if local_assigns[:results]
  json.set! :servers, results.includes(:server).each_with_object({}) { |result, hsh|
    hsh[result.server.hostname] = {
      stage: result.stage,
      action: deploy_workflow_for(deploy).next_action_for(server: result.server, result: result)
    }
  }
end
json.artifact_url deploy.artifact_url
json.completed deploy.completed
json.sha deploy.sha
json.created_at deploy.created_at
