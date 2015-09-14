require_relative "test_helper.rb"
require "canoe"
require "environment_test"

describe Canoe do
  before {
    Console.silence!
    @env = EnvironmentTest.new
    @env.payload = 'pardot'
    #@env.deploy_id = 0
  }

  describe "#call_api" do
    it "should generate appropriate curl command, given path" do
      ShellHelper.expects(:execute_shell).with { |arg| arg.match(%r{api/foo/bar.* -d api_token=}) }
      Canoe.call_api(@env, "api/foo/bar")
    end

    it "should append further params given" do
      ShellHelper.expects(:execute_shell).with { |arg| arg.match(%r{api/foo/bar.* -d chatty=\"saasy}) }
      Canoe.call_api(@env, "api/foo/bar", chatty: "saasy")
    end

    it "should pick out the method from the params" do
      ShellHelper.expects(:execute_shell).with { |arg| arg.match(/FOOBAR/)}
      Canoe.call_api(@env, "api/foo/bar", method: "FOOBAR")
    end

    it "should take the method call out of the regular params" do
      ShellHelper.expects(:execute_shell).with { |arg| !arg.match(/method/)}
      Canoe.call_api(@env, "api/foo/bar", method: "GET")
    end
  end

  describe "#get_current_build" do
    it "should get latest deployed build in canoe" do
      ShellHelper.expects(:execute_shell).with { |arg| arg.match(%r{api/targets/staging/deploys/latest}) }.returns('{"target":"staging","user":"ccornutt@salesforce.com","repo":"pardot","what":"branch","what_details":"ccornutt/PDT-14553","completed":true}')
      branch, _artifact_url = Canoe.get_current_build(@env)
      assert_equal(branch, "ccornutt/PDT-14553")
    end
  end

  #describe "#notify" do
  #  it "should ping deploy complete API end-point" do
  #    ShellHelper.expects(:execute_shell).with { |arg| arg.match(%r{api/deploy/0/complete.* -d api_token=}) }
  #    Canoe.notify(@env)
  #  end
  #end
#
  #describe "#notify_completed_server" do
  #  it "should ping completed server API end-point" do
  #    ShellHelper.expects(:execute_shell).with { |arg| arg.match(%r{api/deploy/0/completed_server.* -d server=\"chatty}) }
  #    Canoe.notify_completed_server(@env, "chatty")
  #  end
  #end

end
