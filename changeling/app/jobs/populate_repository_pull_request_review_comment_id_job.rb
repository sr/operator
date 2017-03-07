class PopulateRepositoryPullRequestReviewCommentIDJob < ActiveJob::Base
  queue_as :default

  def perform
    github_client = GithubInstallation.current.github_client

    Multipass.find_each do |multipass|
      comments = github_client.issue_comments(
        multipass.repository_name,
        multipass.pull_request_number
      )

      compliance_comment = comments.detect do |comment|
        if comment.user.login != Changeling.config.github_service_account_username
          next
        end

        comment.body.include?(RepositoryPullRequest::MAGIC_HTML_COMMENT)
      end

      if compliance_comment
        multipass.update!(github_comment_id: compliance_comment.id)
      end
    end
  end
end
