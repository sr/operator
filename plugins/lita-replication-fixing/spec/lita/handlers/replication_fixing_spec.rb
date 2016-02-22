require "spec_helper"
require "uri"
require "json"

describe Lita::Handlers::ReplicationFixing, lita_handler: true do
  before do
    registry.config.handlers.replication_fixing.pager = "test"
    registry.config.handlers.replication_fixing.monitor_only = false
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

      response = http.post("/replication/errors", URI.encode_www_form(
        "hostname"         => "db-d1",
        "mysql_last_error" => "Query: 'INSERT INTO foo VALUES ('foo@example.com', '1', '1.2')"
      ), {'Content-Type' => 'application/x-www-form-urlencoded'})

      expect(response.status).to eq(201)
      expect(fix_request).to have_been_made
      expect(replies.last).to match(%r{/me is fixing replication on db-d1})
    end

    it "notifies the ops-replication room with a sanitized error messages" do
      stub_request(:get, "https://repfix.pardot.com/replication/fixes/for/db/1/dallas")
        .and_return(
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true)},
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => {"active" => true})},
        )
      stub_request(:post, "https://repfix.pardot.com/replication/fix/db/1")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      response = http.post("/replication/errors", URI.encode_www_form(
        "hostname"         => "db-d1",
        "error"            => "Replication is broken",
        "mysql_last_error" => "Query: 'INSERT INTO foo VALUES ('foo@example.com', '1', '1.2')"
      ), {'Content-Type' => 'application/x-www-form-urlencoded'})

      expect(replies[0]).to eq("db-d1: Replication is broken")
      expect(replies[1]).to eq("db-d1: Query: 'INSERT INTO foo VALUES ([REDACTED], '1', '1.2')")
    end

    it "responds with HTTP 400 if hostname is missing" do
      response = http.post("/replication/errors", URI.encode_www_form({}), {'Content-Type' => 'application/x-www-form-urlencoded'})
      expect(response.status).to eq(400)
    end
  end

  describe "!ignore" do
    it "ignores the shard for 10 minutes by default" do
      send_command("ignore 11")
      expect(replies.last).to eq("/me is ignoring db-11 for 10 minutes")
    end

    it "ignores the shard with a given prefix for 10 minutes by default" do
      send_command("ignore 1 whoisdb")
      expect(replies.last).to eq("/me is ignoring whoisdb-1 for 10 minutes")
    end

    it "allows the number of minutes to be specified" do
      send_command("ignore 11 15")
      expect(replies.last).to eq("/me is ignoring db-11 for 15 minutes")

      send_command("ignore 1 whoisdb 15")
      expect(replies.last).to eq("/me is ignoring whoisdb-1 for 15 minutes")
    end
  end

  describe "!fix" do
    it "attempts to fix the shard" do
      stub_request(:get, "https://repfix.pardot.com/replication/fixes/for/db/11")
        .and_return(
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true)},
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => {"active" => true})},
        )
      stub_request(:post, "https://repfix.pardot.com/replication/fix/db/11")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      send_command("fix 11")
      expect(replies.last).not_to be_nil
    end

    it "attempts to fix the whoisdb shard" do
      stub_request(:get, "https://repfix.pardot.com/replication/fixes/for/whoisdb/1")
        .and_return(
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true)},
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => {"active" => true})},
        )
      stub_request(:post, "https://repfix.pardot.com/replication/fix/whoisdb/1")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      send_command("fix 1 whoisdb")
      expect(replies.last).not_to be_nil
    end
  end
end
