require "spec_helper"
require "json"

describe Lita::Handlers::ReplicationFixing, lita_handler: true do
  describe "POST /replication/errors" do
    it "responds with HTTP 201" do
      response = http.post("/replication/errors", JSON.dump(
        "hostname"         => "db-d1",
        "mysql_last_error" => "Replication failed on db-d9"
      ))

      expect(response.status).to eq(201)
    end

    it "responds with HTTP 400 if mysql_last_error is missing" do
      response = http.post("/replication/errors", JSON.dump({}))
      expect(response.status).to eq(400)
    end
  end
end
