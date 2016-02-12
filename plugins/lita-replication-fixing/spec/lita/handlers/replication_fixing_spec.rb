require "spec_helper"
require "json"

describe Lita::Handlers::ReplicationFixing, lita_handler: true do
  before do
    registry.config.handlers.replication_fixing.pager = "test"
  end

  describe "POST /replication/errors" do
    it "attempts to fix the error and notifies the ops room" do
      stub_request(:get, "https://repfix.tools.pardot.com/replication/fixes/for/db/1/dallas")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))
      fix_request = stub_request(:post, "https://repfix.tools.pardot.com/replication/fix/db/1")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      response = http.post("/replication/errors", JSON.dump(
        "hostname"         => "db-d1",
        "mysql_last_error" => "Replication failed on db-d1"
      ))

      expect(response.status).to eq(201)
      expect(fix_request).to have_been_made
      expect(replies.last).to eq("Fixing replication on db-d1")
    end

    it "responds with HTTP 400 if mysql_last_error is missing" do
      response = http.post("/replication/errors", JSON.dump({}))
      expect(response.status).to eq(400)
    end
  end
end
