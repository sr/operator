# Handle incoming reviews to approve Multipasses
module Multipass::PullRequestReview
  def update_from_review(pull_request, review)
    user = User.find_by(github_login: review["user"]["login"])
    multipass = find_by(reference_url: pull_request["html_url"])
    return unless multipass && user

    unless Changeling.config.review_approval_enabled_for?(user)
      return
    end

    case review["state"]
    when "approved"
      multipass.approve_from_review(user, review["body"], review["html_url"])
    when "rejected"
      multipass.remove_approval_from_review(user, review["body"], review["html_url"])
    end
  end
end
