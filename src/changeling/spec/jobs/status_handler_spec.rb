require "rails_helper"

RSpec.describe StatusHandler do
  before(:each) do
    Changeling.config.pardot = true
  end

  after(:each) do
    Changeling.config.pardot = false
  end

  it "marks the testing status as success if all the required testing status are successful" do
    payload = decoded_fixture_data("github/status_success_travis")
    @multipass = Fabricate(:multipass,
      reference_url: "https://github.com/heroku/changeling/pull/32",
      release_id: payload["commit"]["sha"],
      testing: nil,
    )

    expect(@multipass.testing?).to eq(false)

    payload["context"] = "ci/travis"
    StatusHandler.perform_now(nil, JSON.dump(payload))

    payload["context"] = "ci/bazel"
    StatusHandler.perform_now(nil, JSON.dump(payload))

    expect(@multipass.reload.testing?).to eq(true)
  end

  it "marks the testing status as failure if one of the required testing status is missing" do
    payload = decoded_fixture_data("github/status_success_travis")
    payload["context"] = "ci/travis"

    @multipass = Fabricate(:multipass,
      reference_url: "https://github.com/heroku/changeling/pull/32",
      release_id: payload["commit"]["sha"],
      testing: true,
    )

    expect(@multipass.testing?).to eq(true)
    StatusHandler.perform_now(nil, JSON.dump(payload))
    expect(@multipass.reload.testing?).to eq(false)
  end

  it "updates the status of all matching multipasses" do
    payload = decoded_fixture_data("github/status_failure_travis")
    payload["context"] = "ci/travis"
    @multipass_1 = Fabricate(:multipass,
      reference_url: "https://github.com/heroku/changeling/pull/31",
      release_id: payload["commit"]["sha"],
      testing: true,
    )
    @multipass_2 = Fabricate(:multipass,
      reference_url: "https://github.com/heroku/changeling/pull/32",
      release_id: payload["commit"]["sha"],
      testing: true,
    )

    expect(@multipass_1.testing?).to eq(true)
    expect(@multipass_2.testing?).to eq(true)
    StatusHandler.perform_now(nil, JSON.dump(payload))
    expect(@multipass_1.reload.testing?).to eq(false)
    expect(@multipass_2.reload.testing?).to eq(false)
  end
end
