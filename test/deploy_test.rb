require "test_helper"
require "deploy"

describe Deploy do
  describe ".from_hash" do
    it "constructs a deploy object from its hash representation" do
      json = {
        "id"              => 445,
        "what"            => "branch",
        "what_details"    => "master",
        "artifact_url"    => "https://artifact.example/build1234.tar.gz",
        "server_actions"  => {"server1.example" => nil, "server2.example" => "deploy"},
      }

      deploy = Deploy.from_hash(json)
      deploy.id.must_equal json["id"]
      deploy.what.must_equal json["what"]
      deploy.what_details.must_equal json["what_details"]
      deploy.artifact_url.must_equal json["artifact_url"]
      deploy.server_actions.must_equal json["server_actions"]
    end
  end

  describe "applies_to_this_server?" do
    it "is truthy if this server is in the list of servers" do
      Socket.stubs(:gethostname).returns("localhost1.example.pardot.com")
      deploy = Deploy.from_hash("server_actions" => { "localhost1.example" => nil })

      deploy.applies_to_this_server?.must_equal true
    end

    it "is falsey if this server is not in the list of servers" do
      Socket.stubs(:gethostname).returns("localhost12345.example.pardot.com")
      deploy = Deploy.from_hash("server_actions" => { "localhost1.example" => nil })

      deploy.applies_to_this_server?.must_equal false
    end
  end

  describe ".action" do
    it "is derived from server_actions" do
      deploy = Deploy.from_hash("server_actions" => { "localhost1.example" => nil })
      deploy.action.must_be_nil
    end
  end

  describe ".servers" do
    it "is derived from server_actions" do
      deploy = Deploy.from_hash("server_actions" => { "server1.example" => nil, "server2.example" => "deploy" })
      deploy.servers.must_equal ["server1.example", "server2.example"]
    end
  end
end
