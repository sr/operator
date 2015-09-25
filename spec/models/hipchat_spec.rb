require "rails_helper"

RSpec.describe Hipchat do
  describe "notify_deploy_start" do
    it "with master build" do
      repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
      deploy = FactoryGirl.create(:deploy, build_number: 214, servers_used: 'test-server')
      support_msg = "#{deploy.auth_user.email} just began syncing build214 to Test"
      eng_msg = "Test: #{deploy.auth_user.email} just began " + \
        "syncing Pardot to <a href='https://git.dev.pardot.com/" + \
        "Pardot/pardot/commits/abc123'>build214</a> [test-server]"
      expect(Hipchat).to receive(:notify_room).with(Hipchat::SUPPORT_ROOM, support_msg)
      expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, eng_msg)
      Hipchat.notify_deploy_start(deploy)
    end

    it "with branch build" do
      repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
      deploy = FactoryGirl.create(:deploy, what_details: 'ju/BREAD-111', build_number: 214, servers_used: 'test-server')
      support_msg = "#{deploy.auth_user.email} just began syncing ju/BREAD-111 build214 to Test"
      eng_msg = "Test: #{deploy.auth_user.email} just began " + \
        "syncing Pardot to <a href='https://git.dev.pardot.com/" + \
        "Pardot/pardot/commits/abc123'>ju/BREAD-111 build214</a> [test-server]"
      expect(Hipchat).to receive(:notify_room).with(Hipchat::SUPPORT_ROOM, support_msg)
      expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, eng_msg)
      Hipchat.notify_deploy_start(deploy)
    end

    it "with previous deploy" do
      repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
      deploy_target = FactoryGirl.create(:deploy_target)
      prev_deploy = FactoryGirl.create(:deploy, deploy_target: deploy_target, build_number: 214)
      deploy = FactoryGirl.create(:deploy, deploy_target: deploy_target, what_details: 'ju/BREAD-111', build_number: 214, servers_used: 'test-server')

      support_msg = "#{deploy.auth_user.email} just began syncing ju/BREAD-111 build214 to Test"
      eng_msg = "Test: #{deploy.auth_user.email} just began " + \
        "syncing Pardot to <a href='https://git.dev.pardot.com/" + \
        "Pardot/pardot/commits/abc123'>ju/BREAD-111 build214</a> [test-server]" + \
        "<br>GitHub Diff: <a href='https://git.dev.pardot.com/" + \
        "Pardot/pardot/compare/abc123...abc123'>build214 ... ju/BREAD-111 build214</a>"
      expect(Hipchat).to receive(:notify_room).with(Hipchat::SUPPORT_ROOM, support_msg)
      expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, eng_msg)
      Hipchat.notify_deploy_start(deploy)
    end
  end

  it "should notify_deploy_complete" do
    repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
    deploy = FactoryGirl.create(:deploy, build_number: 214, servers_used: 'test-server')
    support_msg = "#{deploy.auth_user.email} just finished syncing build214 to Test"
    eng_msg = "Test: #{deploy.auth_user.email} just finished " + \
      "syncing Pardot to <a href='https://git.dev.pardot.com/" + \
      "Pardot/pardot/commits/abc123'>build214</a>"
    expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, eng_msg)
    Hipchat.notify_deploy_complete(deploy)
  end

  it "should notify_deploy_cancelled" do
    repo = FactoryGirl.create(:repo) # TODO Remove this when we've added an association btw Deploy & Repo
    deploy = FactoryGirl.create(:deploy, build_number: 214)
    msg = "Test: #{deploy.auth_user.email} just CANCELLED syncing Pardot to build214"
    expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, msg)
    Hipchat.notify_deploy_cancelled(deploy)
  end
end
