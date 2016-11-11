describe PullAgent::Deploy do
  describe ".from_hash" do
    it "constructs a deploy object from its hash representation" do
      json = {
        "id"            => 445,
        "branch"        => "master",
        "artifact_url"  => "https://artifact.example/build1234.tar.gz",
        "servers"       => { "server1.example" => { "action" => nil }, "server2.example" => { "action" => "deploy" } }
      }

      deploy = PullAgent::Deploy.from_hash(json)
      expect(deploy.id).to eq(json["id"])
      expect(deploy.branch).to eq(json["branch"])
      expect(deploy.artifact_url).to eq(json["artifact_url"])
      expect(deploy.server_actions).to eq(json["servers"])
    end
  end

  describe "applies_to_this_server?" do
    it "is truthy if this server is in the list of servers" do
      begin
        orig = ENV["PULL_HOSTNAME"]
        ENV["PULL_HOSTNAME"] = nil
        allow(Socket).to receive(:gethostname).and_return("localhost1.aws.pardot.com")
        deploy = PullAgent::Deploy.from_hash("servers" => { "localhost1" => { "action" => nil } })

        expect(deploy.applies_to_this_server?).to eq(true)
      ensure
        ENV["PULL_HOSTNAME"] = orig
      end
    end

    it "is falsey if this server is not in the list of servers" do
      allow(Socket).to receive(:gethostname).and_return("localhost12345.aws.pardot.com")
      deploy = PullAgent::Deploy.from_hash("servers" => { "localhost1" => { "action" => nil } })

      expect(deploy.applies_to_this_server?).to eq(false)
    end
  end

  describe ".action" do
    it "is derived from server_actions" do
      deploy = PullAgent::Deploy.from_hash("servers" => { "localhost1" => { "action" => nil } })
      expect(deploy.action).to be(nil)
    end
  end

  describe ".servers" do
    it "is derived from server_actions" do
      deploy = PullAgent::Deploy.from_hash("servers" => { "server1" => { "action" => nil }, "server2" => { "action" => "deploy" } })
      expect(deploy.servers).to eq(%w[server1 server2])
    end
  end
end
