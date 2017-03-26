# Worker for handling incoming pull requests review webhooks
class PullRequestReviewHandler < ActiveJob::Base
  def perform(_, data)
    pull_request_review = JSON.parse(data)
    if Changeling.config.pardot?
      multipass = Multipass.find_or_initialize_by_pull_request(pull_request_review)
      multipass.synchronize
    else
      Multipass.update_from_review(pull_request_review["pull_request"],
                                   pull_request_review["review"])
    end
  end
end
