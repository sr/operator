require "rails_helper"

describe MultipassMonitor, type: [:webmock] do
  let(:monitor) { MultipassMonitor.new(false) }

  context "#run" do
    it "logs questionable multipasses" do
      expect(monitor).to receive(:log_questionable)
      monitor.run
    end

    it "repeats logging after nap" do
      monitor = MultipassMonitor.new

      def monitor.nap
        @repeat = false
      end

      expect(monitor).to receive(:log_questionable).twice
      monitor.run
    end
  end

  context "#log_questionable" do
    before do
      create_changeling_multipass_from_pr fixture_data("github/changeling_commit_statuses")
    end

    it "reports an error to rollbar with the multipass id" do
      expect do
        monitor.log_questionable
      end.to_not raise_error
    end
  end
end
