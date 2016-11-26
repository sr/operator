require "rails_helper"

RSpec.describe "Ticket references", type: :request do
  include ActiveJob::TestHelper

  before(:each) do
    Changeling.config.pardot = true
    reference_url = format("https://%s/%s/pull/32",
      Changeling.config.github_hostname,
      PardotRepository::CHANGELING
    )
    @multipass = Fabricate(:multipass,
      reference_url: reference_url,
      release_id: "deadbeef",
      testing: nil
    )
  end

  def create_jira_ticket(external_id)
    jira_event = decoded_fixture_data("jira/issue_updated")
    jira_event["issue"]["key"] = external_id
    post "/events/jira", params: jira_event, as: :json
    expect(response.status).to eq(201)
  end

  def github_pull_request_event(head_sha:, title:)
    payload = decoded_fixture_data("github/pull_request_opened")
    payload["pull_request"]["html_url"] = @multipass.reference_url
    payload["pull_request"]["title"] = title
    payload["pull_request"]["head"]["sha"] = head_sha
    # TODO(sr) Go through the controller layer
    PullRequestHandler.perform_now(nil, JSON.dump(payload))
  end

  it "creates a ticket references for JIRA tickets" do
    create_jira_ticket("BREAD-1598")
    expect(@multipass.ticket_reference).to eq(nil)

    github_pull_request_event(
      head_sha: @multipass.release_id,
      title: "BREAD-1598 Enforce traceability of PR back to ticket",
    )

    expect(@multipass.reload.ticket_reference).to_not eq(nil)
    reference = @multipass.reload.ticket_reference
    expect(reference.ticket_url).to eq("https://jira.dev.pardot.com/browse/BREAD-1598")
  end

  it "updates existing JIRA ticket reference" do
    create_jira_ticket("BREAD-1598")
    github_pull_request_event(
      head_sha: @multipass.release_id,
      title: "BREAD-1598 Enforce traceability of PR back to ticket",
    )
    expect(@multipass.reload.ticket_reference).to_not eq(nil)

    create_jira_ticket("PDT-98")
    github_pull_request_event(
      head_sha: @multipass.release_id,
      title: "PDT-98 Fix everything",
    )

    reference = @multipass.reload.ticket_reference
    expect(reference).to_not eq(nil)
    expect(reference.ticket_url).to eq("https://jira.dev.pardot.com/browse/PDT-98")
  end

  it "removes existing JIRA ticket reference" do
    create_jira_ticket("BREAD-1598")
    github_pull_request_event(
      head_sha: @multipass.release_id,
      title: "BREAD-1598",
    )

    expect(@multipass.reload.ticket_reference).to_not eq(nil)
    github_pull_request_event(head_sha: @multipass.release_id, title: "Untitled")
    expect(@multipass.reload.ticket_reference).to eq(nil)
  end
end
