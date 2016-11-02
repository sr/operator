require "spec_helper"

module Pardot
  module PullAgent
    describe UpstartServiceController do
      it "restarts an upstart service" do
        shell_executor = instance_double("ShellExecutor")
        expect(shell_executor).to receive(:execute)
          .with(["sudo", "/sbin/restart", "fakeservice"], err: [:child, :out])
          .and_return("fakeservice start/running")

        controller = UpstartServiceController.new("fakeservice", shell_executor: shell_executor)
        controller.restart
      end

      it "restarts an upstart service that has not yet been started" do
        shell_executor = instance_double("ShellExecutor")
        expect(shell_executor).to receive(:execute)
          .with(["sudo", "/sbin/restart", "fakeservice"], err: [:child, :out])
          .and_return("Unknown instance")
        expect(shell_executor).to receive(:execute)
          .with(["sudo", "/sbin/start", "fakeservice"], err: [:child, :out])
          .and_return("fakeservice start/running")

        controller = UpstartServiceController.new("fakeservice", shell_executor: shell_executor)
        controller.restart
      end
    end
  end
end
