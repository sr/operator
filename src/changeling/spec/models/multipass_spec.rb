require "rails_helper"

RSpec.describe Multipass, :type => :model do
  let(:user) { Faker::Internet.user_name }
  let(:complete_multipass) { Fabricate.build(:complete_multipass) }
  let(:incomplete_multipass) { Fabricate.build(:incomplete_multipass) }

  describe ".teams" do
    it "returns all unique teams available" do
      5.times { Fabricate(:multipass, team: "Tools") }
      1.times { Fabricate(:multipass, team: "Cedar") }
      3.times { Fabricate(:multipass, team: "API") }
      expect(Multipass.teams).to match_array(%w{Tools Cedar API})
    end
  end

  describe "validation" do
    let(:multipass) { Multipass.new }

    it "fails if requester is missing" do
      expect(multipass).to_not be_valid
    end

    it "fails if reference_url is missing" do
      expect(multipass).to_not be_valid
    end

    it "fails if team is missing" do
      expect do
        complete_multipass.team = nil
      end.to change { complete_multipass.valid? }.from(true).to(false)
    end

    %w{sre_approver peer_reviewer}.each do |actor|
      it "fails if the #{actor} is the same as the requester" do
        complete_multipass.send("#{actor}=", complete_multipass.requester)
        expect(complete_multipass).to_not be_valid
      end

      it "fails if the #{actor} has the same email as the requester" do
        email = "test@heroku.com"
        allow(User).to receive(:for_github_login).and_return nil
        allow(User).to receive(:for_github_login).with(complete_multipass.send(actor)).and_return email

        complete_multipass.requester = email
        expect(complete_multipass).to_not be_valid
      end
    end

    describe "sre_approver" do
      it "fails if sre approver is not in team" do
        multipass.sre_approver = "NOT_A_SRE_USER"
        expect(multipass).to_not be_valid
        expect(multipass.errors[:sre_approver]).to eql ["must be in the GitHub SRE Approvers team"]
      end

      it "works if the user is in the sre team" do
        complete_multipass.change_type = "major"
        complete_multipass.sre_approver = "jmervine"
        expect(complete_multipass).to be_valid
      end

      it "works if case is wrong" do
        complete_multipass.change_type = "major"
        complete_multipass.sre_approver = "jMerViNe"
        expect(complete_multipass).to be_valid
      end
    end
  end

  describe "#repository_name" do
    it "grabs the name with owner from GitHub if it is a pull request" do
      complete_multipass.reference_url = "https://github.com/atmos/hamburgers/pull/42"
      expect(complete_multipass.repository_name).to eql("atmos/hamburgers")
    end

    it "returns nil if the reference_url is not a GitHub pull request" do
      complete_multipass.reference_url = "https://github.com/atmos/hamburgers/issue/42"
      expect(complete_multipass.repository_name).to be nil
    end

    it "supports GitHub Enterprise URLs" do
      complete_multipass.reference_url = "https://git.dev.pardot.com/atmos/hamburgers/pull/42"
      expect(complete_multipass.repository_name).to eql("atmos/hamburgers")
    end
  end

  describe "#pull_request_number" do
    it "grabs the pull request number from GitHub if it is a pull request" do
      complete_multipass.reference_url = "https://github.com/atmos/hamburgers/pull/42"
      expect(complete_multipass.pull_request_number).to eql("42")
    end

    it "returns nil if the reference_url is not a GitHub pull request" do
      complete_multipass.reference_url = "https://notgithub.com/atmos/hamburgers/issue/42"
      expect(complete_multipass.pull_request_number).to be nil
    end

    it "supports GitHub Enterprise URLs" do
      complete_multipass.reference_url = "https://git.dev.pardot.com/atmos/hamburgers/pull/42"
      expect(complete_multipass.pull_request_number).to eql("42")
    end
  end

  describe "multipass with change type preapproved" do
    let(:multipass) { Fabricate(:multipass, change_type: "minor") }
    let(:select_change_type) do
      Proc.new do
        ActiveRecord::Base.connection.execute(
          "SELECT change_type FROM multipasses WHERE uuid = '#{multipass.id}';"
        ).first["change_type"]
      end
    end

    before do
      expect do
        multipass.update_column(:change_type, "preapproved")
      end.to change { select_change_type.call }.from("minor").to("preapproved")
    end

    it "does not call any of our callbacks when modifying the change type" do
      %w{ update_complete callback_to_github }.each do |callback|
        expect_any_instance_of(Multipass).to receive(callback).never
      end

      expect(select_change_type.call).to eql "preapproved"
      expect(multipass.change_type).to eql "minor"
    end

    it "does not update columns that don't have change_type preapproved" do
      %w{ minor major }.each do |change_type|
        multipass.update_column(:change_type, change_type)

        expect_any_instance_of(Multipass).to receive(:update_column).with(:change_type, change_type).never
        expect { multipass.change_type }.not_to change { select_change_type.call }
      end
    end

    it "is updated to have change_type minor when checking it's change_type" do
      expect(select_change_type.call).to eql "preapproved"
      expect { multipass.change_type }.to change { select_change_type.call }.from("preapproved").to("minor")
    end
  end

  describe "#find_questionable" do
    it "returns untested multipasses that were updated 3 minutes ago" do
      questionable = Fabricate(:complete_multipass, updated_at: 3.minutes.ago)
      questionable.update_column(:testing, false)

      expect(Multipass.find_questionable.to_a).to eql [questionable]
    end

    it "does not return untested multipasses that are older than 5 minutes" do
      questionable = Fabricate(:complete_multipass, updated_at: 7.minutes.ago)
      questionable.update_column(:testing, false)

      expect(Multipass.find_questionable.to_a).to eql []
    end
  end

  describe "#approve_from_api_comment" do
    let(:user) { Fabricate(:user, github_login: "ys") }

    it "reconciles testing with GitHub to complete multipasses" do
      create_changeling_multipass_from_pr fixture_data("github/changeling_commit_statuses")
      multipass = Multipass.first
      expect do
        multipass.approve_from_api_comment(user, "+1", "fake-url")
      end.to change { multipass.complete? }.from(false).to(true)
    end
  end

  describe "#approve_from_review" do
    let(:user) { Fabricate(:user, github_login: "ys") }

    it "reconciles testing with GitHub to complete multipasses" do
      create_changeling_multipass_from_pr fixture_data("github/changeling_commit_statuses")
      multipass = Multipass.first
      expect do
        multipass.approve_from_api_comment(user, "I think this is good", "fake-url")
      end.to change { multipass.complete? }.from(false).to(true)
    end
  end

  describe "after_commit #callback_to_github" do
    after(:all) do
      Changeling.config.pardot = false
    end

    it "enqueues job to update the commit status on github" do
      multipass = Fabricate(:multipass)
      expect(GitHubCommitStatusWorker).to receive(:perform_later)
      multipass.update!(testing: true)
    end
  end
end
