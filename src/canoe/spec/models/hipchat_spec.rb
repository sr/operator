require "rails_helper"

RSpec.describe Hipchat do
  describe "notify_deploy_start" do
    it "with master build" do
      project = FactoryGirl.create(:project) # TODO Remove this when we've added an association btw Deploy & Project
      deploy = FactoryGirl.create(:deploy, project_name: project.name, build_number: 214, servers_used: 'test-server')
      support_msg = "#{deploy.auth_user.email} just began syncing build214 to Test"
      eng_msg = "Test: #{deploy.auth_user.email} just began " + \
        "syncing #{project.name.capitalize} to <a href='https://git.dev.pardot.com/" + \
        "Pardot/#{project.name}/commits/abc123'>build214</a> [test-server]"
      expect(Hipchat).to receive(:notify_room).with(Hipchat::SUPPORT_ROOM, support_msg, false)
      expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, eng_msg, false)
      Hipchat.notify_deploy_start(deploy)
    end

    it "with branch build" do
      project = FactoryGirl.create(:project) # TODO Remove this when we've added an association btw Deploy & Project
      deploy = FactoryGirl.create(:deploy, project_name: project.name, what_details: 'ju/BREAD-111', build_number: 214, servers_used: 'test-server')
      support_msg = "#{deploy.auth_user.email} just began syncing ju/BREAD-111 build214 to Test"
      eng_msg = "Test: #{deploy.auth_user.email} just began " + \
        "syncing #{project.name.capitalize} to <a href='https://git.dev.pardot.com/" + \
        "Pardot/#{project.name}/commits/abc123'>ju/BREAD-111 build214</a> [test-server]"
      expect(Hipchat).to receive(:notify_room).with(Hipchat::SUPPORT_ROOM, support_msg, false)
      expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, eng_msg, false)
      Hipchat.notify_deploy_start(deploy)
    end

    it "with previous deploy" do
      project = FactoryGirl.create(:project) # TODO Remove this when we've added an association btw Deploy & Project
      deploy_target = FactoryGirl.create(:deploy_target)
      prev_deploy = FactoryGirl.create(:deploy, project_name: project.name, deploy_target: deploy_target, build_number: 214)
      deploy = FactoryGirl.create(:deploy, project_name: project.name, deploy_target: deploy_target, what_details: 'ju/BREAD-111', build_number: 214, servers_used: 'test-server')

      support_msg = "#{deploy.auth_user.email} just began syncing ju/BREAD-111 build214 to Test"
      eng_msg = "Test: #{deploy.auth_user.email} just began " + \
        "syncing #{project.name.capitalize} to <a href='https://git.dev.pardot.com/" + \
        "Pardot/#{project.name}/commits/abc123'>ju/BREAD-111 build214</a> [test-server]" + \
        "<br>GitHub Diff: <a href='https://git.dev.pardot.com/" + \
        "Pardot/#{project.name}/compare/abc123...abc123'>build214 ... ju/BREAD-111 build214</a>"
      expect(Hipchat).to receive(:notify_room).with(Hipchat::SUPPORT_ROOM, support_msg, false)
      expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, eng_msg, false)
      Hipchat.notify_deploy_start(deploy)
    end
  end

  it "should notify_deploy_complete" do
    project = FactoryGirl.create(:project) # TODO Remove this when we've added an association btw Deploy & Project
    deploy = FactoryGirl.create(:deploy, project_name: project.name, build_number: 214, servers_used: 'test-server')
    support_msg = "#{deploy.auth_user.email} just finished syncing build214 to Test"
    eng_msg = "Test: #{deploy.auth_user.email} just finished " + \
      "syncing #{project.name.capitalize} to <a href='https://git.dev.pardot.com/" + \
      "Pardot/#{project.name}/commits/abc123'>build214</a>"
    expect(Hipchat).to receive(:notify_room).with(Hipchat::SUPPORT_ROOM, support_msg, false)
    expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, eng_msg, false)
    Hipchat.notify_deploy_complete(deploy)
  end

  it "should notify_deploy_cancelled" do
    project = FactoryGirl.create(:project) # TODO Remove this when we've added an association btw Deploy & Project
    deploy = FactoryGirl.create(:deploy, project_name: project.name, build_number: 214)
    msg = "Test: #{deploy.auth_user.email} just CANCELLED syncing #{project.name.capitalize} to build214"
    expect(Hipchat).to receive(:notify_room).with(Hipchat::SUPPORT_ROOM, msg, false)
    expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, msg, false)
    Hipchat.notify_deploy_cancelled(deploy)
  end

  it "should not notify_untested_deploy because we're in test" do
    project = FactoryGirl.create(:project) # TODO Remove this when we've added an association btw Deploy & Project
    deploy = FactoryGirl.create(:deploy, project_name: project.name, build_number: 214, passed_ci: false)
    msg = "Test: #{deploy.auth_user.email} just started an UNTESTED deploy of #{deploy.project_name.capitalize} to build214"
    expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, msg, false, "red").never
  end

  it "should notify_untested_deploy" do
    project = FactoryGirl.create(:project) # TODO Remove this when we've added an association btw Deploy & Project
    deploy = FactoryGirl.create(:deploy, project_name: project.name, build_number: 214, passed_ci: false)
    msg = "Test: #{deploy.auth_user.email} just started an UNTESTED deploy of #{deploy.project_name.capitalize} to build214"
    expect(Hipchat).to receive(:notify_room).with(Hipchat::ENG_ROOM, msg, false, "red")
    Hipchat.notify_untested_deploy(deploy)
  end
end
