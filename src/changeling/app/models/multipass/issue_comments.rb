# Handle incoming issue comments to approve Multipasses
module Multipass::IssueComments
  def update_from_issue_comment(pull_request, comment, text)
    return unless pull_request
    user = User.find_by(github_login: comment["user"]["login"])
    multipass = find_by(reference_url: pull_request["html_url"])
    return unless multipass && user

    multipass.approve_from_api_comment(user, text, comment["html_url"])
  end
end
