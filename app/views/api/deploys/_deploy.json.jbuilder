json.id deploy.id
json.target deploy.deploy_target.name
json.user deploy.auth_user.email
json.repo deploy.repo_name
json.what deploy.what
json.what_details deploy.what_details
json.build_number deploy.build_number
if local_assigns[:results]
  json.set! :servers, results.includes(:server).each_with_object({}) { |result, hsh|
    hsh[result.server.hostname] = {
      stage: result.stage,
      action: workflow_for(deploy: deploy).next_action_for(server: result.server, result: result)
    }
  }
end
json.artifact_url deploy.artifact_url
json.completed deploy.completed
json.sha deploy.sha
json.created_at deploy.created_at
