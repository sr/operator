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
      return unless issue_comment["issue"] && issue_comment["issue"]["pull_request"]

      multipass = Multipass.find_by(reference_url: issue_comment["issue"]["pull_request"]["html_url"])
      multipass.synchronize if multipass
    elsif valid_issue_comment?(issue_comment["comment"]["body"])
      Multipass.update_from_issue_comment(issue_comment["issue"]["pull_request"],
        issue_comment["comment"], ":+1:")
    else
      Rails.logger.info "Ignoring issue comment: #{issue_comment['comment']['body']}"
    end
  end
end
