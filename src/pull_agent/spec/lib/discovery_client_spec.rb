require "spec_helper"

describe PullAgent::DiscoveryClient do
  describe "#service" do
    it "retrieves a list for the specified service" do
      stub_request(:get, "http://127.0.0.1:8383/v1/service/redis-job-1")
        .to_return(
          status: 200,
          body: JSON.dump([
            {
              "address" => "job-d1.dev",
              "id" => "2559d2dc-d1d6-46aa-8913-6d835ac9da99",
              "name" => "redis-job-1",
              "payload" => {
                "datacenter" => "seattle",
                "role" => "master",
                "syncCompleted" => false
              },
              "port" => 6379,
              "registrationTimeUTC" => 1_450_725_494_953,
              "serviceType" => "DYNAMIC",
              "sslPort" => nil,
              "uriSpec" => nil
            }
          ])
        )

      servers = PullAgent::DiscoveryClient.new.service("redis-job-1")
      expect(servers.length).to eq(1)
      expect(servers[0]["address"]).to eq("job-d1.dev")
    end

    it "raises an error if the service is unavailable" do
      stub_request(:get, "http://127.0.0.1:8383/v1/service/redis-job-1")
        .to_return(status: 503)

      expect {
        PullAgent::DiscoveryClient.new.service("redis-job-1")
      }.to raise_error(PullAgent::DiscoveryClient::Error)
    end
  end
end
