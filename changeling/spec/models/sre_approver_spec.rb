require "rails_helper"

describe SREApprover do
  describe ".all" do
    it "returns a list of users from the SRE Approvers team" do
      users = SREApprover.all
      expect(users.length).to eql(6)
      expect(users[0].github_login).to eql("cmeckhardt")
      expect(users[0].github_uid).to eql(6_923_638)
    end
  end
end
