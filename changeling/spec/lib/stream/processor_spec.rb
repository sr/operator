require "rails_helper"

describe Stream::Processor do
  describe "#run" do
    it "sends errors to Librato" do
      processor = Stream::Processor.new
      allow(processor)
        .to receive(:read_from_stream)
        .and_raise(Tonitrus::Errors::AuthorizationError)

      expect(Librato).to receive(:increment)
        .with("tonitrus.error.authorization_error")

      processor.run
    end
  end
end
