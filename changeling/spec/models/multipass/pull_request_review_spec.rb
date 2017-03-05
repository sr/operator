require "rails_helper"

RSpec.describe Multipass::PullRequestReview do
  let(:hook) { decoded_fixture_data("github/pull_request_review_approved") }

  before do
    User.create!(github_login: "ys")
    User.create!(github_login: "atmos")
  end

  it "approves a multipass if state is approved" do
    hook = decoded_fixture_data("github/pull_request_review_approved")
    multipass = Fabricate(:incomplete_multipass,
                           reference_url: hook["pull_request"]["html_url"],
                           impact: "low",
                           impact_probability: "low",
                           change_type: ChangeCategorization::STANDARD,
                           testing: true,
                           requester: "atmos")
    expect do
      Multipass.update_from_review(hook["pull_request"], hook["review"])
    end.to change { multipass.reload.complete? }.from(false).to(true)
  end

  it "unapproves a multipass if state is rejected" do
    hook = decoded_fixture_data("github/pull_request_review_rejected")
    multipass = Fabricate(:incomplete_multipass,
                           reference_url: hook["pull_request"]["html_url"],
                           impact: "low",
                           impact_probability: "low",
                           change_type: ChangeCategorization::STANDARD,
                           testing: true,
                           complete: true,
                           peer_reviewer: "atmos",
                           requester: "ys")
    expect do
      Multipass.update_from_review(hook["pull_request"], hook["review"])
    end.to change { multipass.reload.complete? }.from(true).to(false)
  end
end
