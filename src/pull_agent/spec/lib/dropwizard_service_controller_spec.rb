require "spec_helper"

module Pardot
  module PullAgent
    describe DropwizardServiceController do
      it "restarts the underlying service" do
        underlying_service = instance_double("UpstartServiceController")
        expect(underlying_service).to receive(:restart)

        controller = DropwizardServiceController.new(underlying_service)
        controller.restart
      end

      context "with a play dead controller" do
        it "requests the service play dead before restarting" do
          underlying_service = instance_double("UpstartServiceController")
          allow(underlying_service).to receive(:restart)

          play_dead_controller = instance_double("PlayDeadController")
          expect(play_dead_controller).to receive(:make_play_dead)
          expect(play_dead_controller).to receive(:make_alive)

          controller = DropwizardServiceController.new(
            underlying_service,
            play_dead_controller: play_dead_controller,
          )
          controller.restart_wait_time = 0.1
          controller.play_dead_wait_time = 0.1

          controller.restart
        end

        it "retries to make the service alive if the service does not come back up immediately" do
          underlying_service = instance_double("UpstartServiceController")
          allow(underlying_service).to receive(:restart)

          play_dead_controller = instance_double("PlayDeadController")
          allow(play_dead_controller).to receive(:make_play_dead)

          first_time = true
          allow(play_dead_controller).to receive(:make_alive) do
            if first_time
              first_time = false
              raise IOError
            else
              true
            end
          end

          controller = DropwizardServiceController.new(
            underlying_service,
            play_dead_controller: play_dead_controller,
          )
          controller.restart_wait_time = 1
          controller.play_dead_wait_time = 0.1

          controller.restart
        end

        it "times out if service doesn't come back up" do
          underlying_service = instance_double("UpstartServiceController")
          allow(underlying_service).to receive(:restart)

          play_dead_controller = instance_double("PlayDeadController")
          allow(play_dead_controller).to receive(:make_play_dead)
          allow(play_dead_controller).to receive(:make_alive).and_raise(IOError)

          controller = DropwizardServiceController.new(
            underlying_service,
            play_dead_controller: play_dead_controller,
          )
          controller.restart_wait_time = 1
          controller.play_dead_wait_time = 0.1

          expect {
            controller.restart
          }.to raise_error(DropwizardServiceController::RestartUnsuccessfulError)
        end
      end
    end
  end
end
