require "rails_helper"

RSpec.describe Deploy do
  describe "completion" do
    it "is not complete if the process is still running" do
      repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
      deploy = FactoryGirl.create(:deploy, repo_name: repo.name, completed: false, process_id: "12345")
      allow(Process).to receive(:kill).with(0, 12345).and_return(1)

      deploy.check_completed_status!
      expect(deploy.completed?).to be_falsey
    end

    it "is not complete if a server is still pending" do
      repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
      deploy = FactoryGirl.create(:deploy, repo_name: repo.name, completed: false)
      server = FactoryGirl.create(:server)
      deploy.results.create!(server: server, stage: "initiated")

      deploy.check_completed_status!
      expect(deploy.completed?).to be_falsey
    end

    it  "is complete if the process is dead and all results are completed or failed" do
      repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
      deploy = FactoryGirl.create(:deploy, repo_name: repo.name, completed: false, process_id: "12345")
      allow(Process).to receive(:kill).with(0, 12345).and_raise(Errno::ESRCH)

      server = FactoryGirl.create(:server)
      deploy.results.create!(server: server, stage: "completed")

      deploy.check_completed_status!
      expect(deploy.completed?).to be_truthy
    end
  end
end
