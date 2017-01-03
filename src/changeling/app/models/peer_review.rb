class PeerReview < ApplicationRecord
  def self.synchronize(multipass, pull_request_reviews)
    if multipass.nil?
      raise ArgumentError, "multipass is nil"
    end

    if multipass.new_record?
      raise ArgumentError, "multipass is a new record"
    end

    Array(pull_request_reviews).map do |review|
      peer_review = PeerReview.find_or_initialize_by(
        multipass_id: multipass.id,
        reviewer_github_login: review.user.login
      )
      peer_review.update!(state: review.state)
      peer_review
    end
  end
end
