# Worker for handling incoming pull requests review webhooks
class PullRequestReviewHandler < ActiveJob::Base
  def perform(_, data)
    pull_request_review = JSON.parse(data)
    Multipass.update_from_review(pull_request_review["pull_request"],
                                 pull_request_review["review"])
  end
end
