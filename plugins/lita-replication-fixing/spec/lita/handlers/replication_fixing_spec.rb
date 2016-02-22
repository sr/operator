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
      expect(replies.last).to match(%r{/me is fixing replication on db-1})
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
      expect(replies.last).to eq("OK, I will ignore db-11 for 10 minutes")
    end

    it "ignores the shard with a given prefix for 10 minutes by default" do
      send_command("ignore 1 whoisdb")
      expect(replies.last).to eq("OK, I will ignore whoisdb-1 for 10 minutes")
    end

    it "allows the number of minutes to be specified" do
      send_command("ignore 11 15")
      expect(replies.last).to eq("OK, I will ignore db-11 for 15 minutes")

      send_command("ignore 1 whoisdb 15")
      expect(replies.last).to eq("OK, I will ignore whoisdb-1 for 15 minutes")
    end
  end

  describe "!fix" do
    it "attempts to fix the shard" do
      stub_request(:get, "https://repfix.pardot.com/replication/fixes/for/db/11")
        .and_return(
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true)},
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => {"active" => true})},
        )
      request = stub_request(:post, "https://repfix.pardot.com/replication/fix/db/11")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      send_command("fix 11")
      expect(replies.last).to eq("OK, I'm trying to fix db-11")
      expect(request).to have_been_made
    end

    it "attempts to fix the whoisdb shard" do
      stub_request(:get, "https://repfix.pardot.com/replication/fixes/for/whoisdb/1")
        .and_return(
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true)},
          {body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => {"active" => true})},
        )
      request = stub_request(:post, "https://repfix.pardot.com/replication/fix/whoisdb/1")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      send_command("fix 1 whoisdb")
      expect(replies.last).to eq("OK, I'm trying to fix whoisdb-1")
      expect(request).to have_been_made
    end
  end

  describe "!cancelfix" do
    it "cancels the fix for the shard" do
      request = stub_request(:post, "https://repfix.pardot.com/replication/fixes/cancel/11")
        .and_return(body: JSON.dump("is_canceled" => true, "message" => "Fixes canceled"))

      send_command("cancelfix 11")
      expect(replies.last).to eq("OK, I cancelled all the fixes for db-11")
      expect(request).to have_been_made
    end
  end

  describe "!resetignore" do
    it "resets the ignore for the shard" do
      send_command("resetignore 11")
      expect(replies.last).to eq("OK, I will no longer ignore db-11")
    end

    it "resets the ignore for the shard with a given prefix" do
      send_command("resetignore 1 whoisdb")
      expect(replies.last).to eq("OK, I will no longer ignore whoisdb-1")
    end
  end

  describe "!currentautofixes" do
    it "lists the fixes currently ongoing" do
      fixing_status_client = ::ReplicationFixing::FixingStatusClient.new(subject.redis)
      fixing_status_client.ensure_fixing_status_ongoing(shard: ::ReplicationFixing::Shard.new("db", 12))
      fixing_status_client.ensure_fixing_status_ongoing(shard: ::ReplicationFixing::Shard.new("db", 32))

      send_command("currentautofixes")
      expect(replies.last).to eq("I'm currently fixing: db-12, db-32")
    end
  end

  describe "!stopfixing and !startfixing" do
    it "globally stops and starts fixing" do
      send_command("stopfixing")
      expect(replies.last).to eq("OK, I've stopped fixing replication for ALL shards")

      send_command("checkfixing")
      expect(replies.last).to eq("(nope) Replication fixing is globally disabled")

      send_command("startfixing")
      expect(replies.last).to eq("OK, I've started fixing replication")

      send_command("checkfixing")
      expect(replies.last).to eq("(goodnews) Replication fixing is globally enabled")
    end
  end
end
