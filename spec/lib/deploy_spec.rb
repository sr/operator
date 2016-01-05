require "deploy"

describe Deploy do
  describe ".from_hash" do
    it "constructs a deploy object from its hash representation" do
      json = {
        "id"            => 445,
        "what"          => "branch",
        "what_details"  => "master",
        "artifact_url"  => "https://artifact.example/build1234.tar.gz",
        "servers"       => {"server1.example" => {"action" => nil}, "server2.example" => {"action" => "deploy"}},
      }

      deploy = Deploy.from_hash(json)
      expect(deploy.id).to eq(json["id"])
      expect(deploy.what).to eq(json["what"])
      expect(deploy.what_details).to eq(json["what_details"])
      expect(deploy.artifact_url).to eq(json["artifact_url"])
      expect(deploy.server_actions).to eq(json["servers"])
    end
  end

  describe "applies_to_this_server?" do
    it "is truthy if this server is in the list of servers" do
      allow(Socket).to receive(:gethostname).and_return("localhost1.example.pardot.com")
      deploy = Deploy.from_hash("servers" => {"localhost1.example" => {"action" => nil}})

      expect(deploy.applies_to_this_server?).to eq(true)
    end

    it "is falsey if this server is not in the list of servers" do
      allow(Socket).to receive(:gethostname).and_return("localhost12345.example.pardot.com")
      deploy = Deploy.from_hash("servers" => {"localhost1.example" => {"action" => nil}})

      expect(deploy.applies_to_this_server?).to eq(false)
    end
  end

  describe ".action" do
    it "is derived from server_actions" do
      deploy = Deploy.from_hash("servers" => {"localhost1.example" => {"action" => nil}})
      expect(deploy.action).to be(nil)
    end
  end

  describe ".servers" do
    it "is derived from server_actions" do
      deploy = Deploy.from_hash("servers" => {"server1.example" => {"action" => nil}, "server2.example" => {"action" => "deploy"}})
      expect(deploy.servers).to eq(["server1.example", "server2.example"])
    end
  end
end
