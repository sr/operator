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

  it "should pull key from passed options hash" do
    key = "~/.ssh/test.pub"
    payload = Payload.new(key: key)
    payload.key.must_equal(key)
  end

  it "should pull local_path from passed options hash" do
    path = "/tmp/"
    payload = Payload.new(local_path: path)
    payload.local_git_path.must_equal(path+"github")
  end

  it "should make sure local_path ends with trailing /" do
    path = "/tmp"
    payload = Payload.new(local_path: path)
    payload.local_git_path.must_equal(path+"/github")
  end

  it "should pull remote_path from passed options hash" do
    path = "/var/www/"
    payload = Payload.new(remote_path: path)
    payload.remote_path.must_equal(path)
  end

  it "should pull remote_html_path from passed options hash" do
    path = "/var/www/"
    payload = Payload.new(remote_html_path: path)
    payload.remote_html_path.must_equal(path)
  end

end
