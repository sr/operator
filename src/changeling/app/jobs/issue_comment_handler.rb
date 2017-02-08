# -*- coding: utf-8 -*-
# Worker for handling incoming issue_comment events
class IssueCommentHandler < ActiveJob::Base
  ACCEPTED_PEER_REVIEW_COMMENTS = [
    "👍", "👍🏻", "👍🏼", "👍🏽", "👍🏾", "👍🏿",
    ":+1:", "+1", ":shipit:", "lgtm", "looks good to me"
  ].freeze

  def valid_issue_comment?(body)
    body.downcase.strip.start_with?(*ACCEPTED_PEER_REVIEW_COMMENTS) ||
      body.downcase.strip.end_with?(*ACCEPTED_PEER_REVIEW_COMMENTS)
  end

  def perform(_, data)
    issue_comment = JSON.parse(data)
    if Changeling.config.pardot?
      multipass = Multipass.find_or_initialize_by_pull_request(issue_comment["issue"]["pull_request"])
      multipass.save!
      multipass.synchronize
    elsif valid_issue_comment?(issue_comment["comment"]["body"])
      Multipass.update_from_issue_comment(issue_comment["issue"]["pull_request"],
        issue_comment["comment"], ":+1:")
    else
      Rails.logger.info "Ignoring issue comment: #{issue_comment['comment']['body']}"
    end
  end
end
