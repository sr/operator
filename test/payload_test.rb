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

  it "should default to the current symlink if not given" do
    id = :pardot
    payload = Payload.new(id: id)
    File.basename(payload.current_link).must_equal("current")
  end

  it "should use to the current symlink given" do
    id = :pardot
    payload = Payload.new(id: id, current_link: '/current-pi')
    File.basename(payload.current_link).must_equal("current-pi")
  end

  it "should default to the path_choices if not given" do
    id = :pardot
    payload = Payload.new(id: id)
    repo_dir = File.expand_path(File.dirname(File.dirname(__FILE__)))
    payload.path_choices.must_equal(['releases/A', 'releases/B'].map{|p| File.expand_path(p, repo_dir)})
  end
end
