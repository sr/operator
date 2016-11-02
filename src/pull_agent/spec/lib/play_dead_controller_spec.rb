require "spec_helper"

module Pardot
  module PullAgent
    describe PlayDeadController do
      context "playing dead" do
        it "requests that the service 'play dead'" do
          req = stub_request(:put, "http://localhost:8090/admin-tools/ready").to_return(status: 200)

          controller = PlayDeadController.new(8090)
          controller.make_play_dead

          expect(req).to have_been_requested
        end

        it "raises an error if not successful" do
          stub_request(:put, "http://localhost:8090/admin-tools/ready").to_return(status: 500)

          controller = PlayDeadController.new(8090)
          expect {
            controller.make_play_dead
          }.to raise_error
        end
      end

      context "coming back to life" do
        it "requests that the service come back to life" do
          req = stub_request(:delete, "http://localhost:8090/admin-tools/ready").to_return(status: 200)

          controller = PlayDeadController.new(8090)
          controller.make_alive

          expect(req).to have_been_requested
        end

        it "raises an error if not successful" do
          stub_request(:delete, "http://localhost:8090/admin-tools/ready").to_return(status: 500)

          controller = PlayDeadController.new(8090)
          expect {
            controller.make_alive
          }.to raise_error
        end
      end
    end
  end
end
