require_relative "test_helper.rb"
require "payload"

describe Payload do
  it "should pull id from passed options hash" do
    id = :pardot
    payload = Payload.new(id: id)
    payload.id.must_equal(id)
  end

  it "should derive name from id" do
    id = :pardot
    payload = Payload.new(id: id)
    payload.name.must_equal("Pardot")
  end

  it "should make name camelcase of id" do
    id = :pardot_stuff
    payload = Payload.new(id: id)
    payload.name.must_equal("PardotStuff")
  end
end
