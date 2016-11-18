require "rails_helper"

RSpec.describe Metrics do
  it "does not prepend the source if prepend_source is false" do
    expect(Librato).to receive(:increment).with("lol", anything)
    Metrics.increment("lol", prepend_source: false)
  end

  it "prepends the source if prepend_source is not an argument" do
    expect(Librato).to receive(:increment).with("changeling-development.lol", anything)
    Metrics.increment("lol")
  end

  it "prepends the source if prepend_source is true" do
    expect(Librato).to receive(:increment).with("changeling-development.lol", anything)
    Metrics.increment("lol", prepend_source: true)
  end
end
