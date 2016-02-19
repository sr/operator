require "spec_helper"
require "json"

describe Lita::Handlers::ReplicationFixing, lita_handler: true do
  before do
    registry.config.handlers.replication_fixing.pager = "test"
  end

  describe "POST /replication/errors" do
    it "attempts to fix the error and notifies the ops room" do
      stub_request(:get, "https://repfix.pardot.com/replication/fixes/for/db/1/dallas")
        .and_return(
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true)},
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => {"active" => true})},
        )
      fix_request = stub_request(:post, "https://repfix.pardot.com/replication/fix/db/1")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      response = http.post("/replication/errors", JSON.dump(
        "hostname"         => "db-d1",
        "mysql_last_error" => "Query: 'INSERT INTO foo VALUES ('foo@example.com', '1', '1.2')"
      ))

      expect(response.status).to eq(201)
      expect(fix_request).to have_been_made
      expect(replies.last).to match(%r{/me is fixing replication on db-d1})
    end

    it "notifies the ops-replication room with a sanitized error message" do
      stub_request(:get, "https://repfix.pardot.com/replication/fixes/for/db/1/dallas")
        .and_return(
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true)},
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => {"active" => true})},
        )
      stub_request(:post, "https://repfix.pardot.com/replication/fix/db/1")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      response = http.post("/replication/errors", JSON.dump(
        "hostname"         => "db-d1",
        "mysql_last_error" => "Query: 'INSERT INTO foo VALUES ('foo@example.com', '1', '1.2')"
      ))

      expect(replies.first).to eq("db-d1: Query: 'INSERT INTO foo VALUES ([REDACTED], '1', '1.2')")
    end

    it "responds with HTTP 400 if mysql_last_error is missing" do
      response = http.post("/replication/errors", JSON.dump({}))
      expect(response.status).to eq(400)
    end
  end
end
