require "spec_helper"
require "uri"

describe ReplicationFixingHandler, lita_handler: true do
  before do
    registry.config.handlers.replication_fixing_handler.pager = "test"
  end

  describe "POST /replication/errors" do
    it "attempts to fix the error and notifies the ops room" do
      pending "This needs to be migrated to gRPC"
      stub_request(:get, "https://repfix-phx.pardot.com/replication/fixes/for/db/1/1")
        .and_return(
          { body: JSON.dump("is_erroring" => true, "is_fixable" => true) },
          body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => { "active" => true })
        )
      fix_request = stub_request(:post, "https://repfix-phx.pardot.com/replication/fix/db/1")
                    .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      response = http.post("/replication/errors",
                           URI.encode_www_form(
                             "hostname"         => "pardot0-dbshard1-1-phx",
                             "mysql_last_error" => "Query: 'INSERT INTO foo VALUES ('foo@example.com', '1', '1.2')"
                           ), "Content-Type" => "application/x-www-form-urlencoded")

      expect(response.status).to eq(201)
      expect(fix_request).to have_been_made
      expect(replies.last).to match(/I am fixing replication on db-1/)
    end

    it "notifies the ops-replication room with a sanitized error messages" do
      pending "This needs to be migrated to gRPC"
      stub_request(:get, "https://repfix-phx.pardot.com/replication/fixes/for/db/1/1")
        .and_return(
          { body: JSON.dump("is_erroring" => true, "is_fixable" => true) },
          body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => { "active" => true })
        )
      stub_request(:post, "https://repfix-phx.pardot.com/replication/fix/db/1")
        .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      response = http.post("/replication/errors",
                           URI.encode_www_form(
                             "hostname"         => "pardot0-dbshard1-1-phx",
                             "error"            => "Replication is broken",
                             "mysql_last_error" => "Query: 'INSERT INTO foo VALUES ('foo@example.com', '1', '1.2')"
                           ), "Content-Type" => "application/x-www-form-urlencoded")

      expect(replies[0]).to eq("pardot0-dbshard1-1-phx: Replication is broken")
      expect(replies[1]).to eq("pardot0-dbshard1-1-phx: Query: 'INSERT INTO foo VALUES ([REDACTED], '1', '1.2')")
    end

    it "responds with HTTP 400 if hostname is missing" do
      pending "This needs to be migrated to gRPC"
      response = http.post("/replication/errors",
                           URI.encode_www_form({}),
                           "Content-Type" => "application/x-www-form-urlencoded")
      expect(response.status).to eq(400)
    end
  end

  describe "!ignore" do
    it "ignores the shard for 15 minutes by default" do
      send_command("ignore 11")
      expect(replies.last).to eq("OK, I will ignore db-11-phx for 15 minutes")
    end

    it "ignores the shard with a given prefix for 15 minutes by default" do
      send_command("ignore whoisdb-1")
      expect(replies.last).to eq("OK, I will ignore whoisdb-1-phx for 15 minutes")
    end

    it "ignores the shard in DFW" do
      send_command("ignore 11-dfw")
      expect(replies.last).to eq("OK, I will ignore db-11-dfw for 15 minutes")
    end

    it "allows the number of minutes to be specified" do
      send_command("ignore 11 10")
      expect(replies.last).to eq("OK, I will ignore db-11-phx for 10 minutes")

      send_command("ignore whoisdb-1 10")
      expect(replies.last).to eq("OK, I will ignore whoisdb-1-phx for 10 minutes")
    end
  end

  describe "!fix" do
    it "attempts to fix the shard" do
      stub_request(:get, "https://repfix-phx.pardot.com/replication/fixes/for/db/11")
        .and_return(
          { body: JSON.dump("is_erroring" => true, "is_fixable" => true) },
          body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => { "active" => true })
        )
      request = stub_request(:post, "https://repfix-phx.pardot.com/replication/fix/db/11")
                .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      send_command("fix 11")
      expect(replies.last).to eq("OK, I'm trying to fix db-11-phx")
      expect(request).to have_been_made
    end

    it "attempts to fix the whoisdb shard" do
      stub_request(:get, "https://repfix-phx.pardot.com/replication/fixes/for/whoisdb/1")
        .and_return(
          { body: JSON.dump("is_erroring" => true, "is_fixable" => true) },
          body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => { "active" => true })
        )
      request = stub_request(:post, "https://repfix-phx.pardot.com/replication/fix/whoisdb/1")
                .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      send_command("fix whoisdb-1")
      expect(replies.last).to eq("OK, I'm trying to fix whoisdb-1-phx")
      expect(request).to have_been_made
    end

    it "attempts to fix the shard in DFW" do
      stub_request(:get, "https://repfix-dfw.pardot.com/replication/fixes/for/db/11")
        .and_return(
          { body: JSON.dump("is_erroring" => true, "is_fixable" => true) },
          body: JSON.dump("is_erroring" => true, "is_fixable" => true, "fix" => { "active" => true })
        )
      request = stub_request(:post, "https://repfix-dfw.pardot.com/replication/fix/db/11")
                .and_return(body: JSON.dump("is_erroring" => true, "is_fixable" => true))

      send_command("fix 11-dfw")
      expect(replies.last).to eq("OK, I'm trying to fix db-11-dfw")
      expect(request).to have_been_made
    end

    it "rejects an invalid datacenter" do
      send_command("fix 11-nope")
      expect(replies.last).to eq("Sorry, no such datacenter: nope")
    end
  end

  describe "!cancelfix" do
    it "cancels the fix for the shard" do
      request = stub_request(:post, "https://repfix-phx.pardot.com/replication/fixes/cancel/11")
                .and_return(body: JSON.dump("is_canceled" => true, "message" => "Fixes canceled"))

      send_command("cancelfix 11")
      expect(replies.last).to eq("OK, I cancelled all the fixes for db-11-phx")
      expect(request).to have_been_made
    end

    it "cancels the fix for the shard in DFW" do
      request = stub_request(:post, "https://repfix-dfw.pardot.com/replication/fixes/cancel/11")
                .and_return(body: JSON.dump("is_canceled" => true, "message" => "Fixes canceled"))

      send_command("cancelfix 11-dfw")
      expect(replies.last).to eq("OK, I cancelled all the fixes for db-11-dfw")
      expect(request).to have_been_made
    end

    it "rejects an invalid datacenter" do
      send_command("cancelfix 11-nope")
      expect(replies.last).to eq("Sorry, no such datacenter: nope")
    end
  end

  describe "!resetignore" do
    it "resets the ignore for the shard" do
      send_command("resetignore 11")
      expect(replies.last).to eq("OK, I will no longer ignore db-11-phx")
    end

    it "resets the ignore for the shard in DFW" do
      send_command("resetignore 11-dfw")
      expect(replies.last).to eq("OK, I will no longer ignore db-11-dfw")
    end

    it "resets the ignore for the shard with a given prefix" do
      send_command("resetignore whoisdb-1")
      expect(replies.last).to eq("OK, I will no longer ignore whoisdb-1-phx")
    end
  end

  describe "!currentautofixes" do
    it "lists the fixes currently ongoing" do
      fixing_status_client = ::ReplicationFixing::FixingStatusClient.new("phx", subject.redis)
      fixing_status_client.set_active(shard: ::ReplicationFixing::Shard.new("db", 12, "phx"), active: true)
      fixing_status_client.set_active(shard: ::ReplicationFixing::Shard.new("db", 32, "phx"), active: false)

      send_command("currentautofixes")
      expect(replies.last).to eq("I'm currently fixing: db-12-phx")
    end
  end

  describe "!stopfixing and !startfixing" do
    it "globally stops and starts fixing" do
      send_command("stopfixing")
      expect(replies.last).to eq("OK, I've stopped fixing replication for ALL shards")

      send_command("checkfixing")
      expect(replies.last).to eq("(nope) Replication fixing is globally disabled in phx")

      send_command("startfixing")
      expect(replies.last).to eq("OK, I've started fixing replication")

      send_command("checkfixing")
      expect(replies.last).to eq("(goodnews) Replication fixing is globally enabled in phx")
    end

    it "globally stops and starts fixing in DFW" do
      send_command("stopfixing dfw")
      expect(replies.last).to eq("OK, I've stopped fixing replication for ALL shards")

      send_command("checkfixing dfw")
      expect(replies.last).to eq("(nope) Replication fixing is globally disabled in dfw")

      send_command("startfixing dfw")
      expect(replies.last).to eq("OK, I've started fixing replication")

      send_command("checkfixing dfw")
      expect(replies.last).to eq("(goodnews) Replication fixing is globally enabled in dfw")
    end
  end

  describe "!status" do
    it "prints the status of each database host" do
      response = {
        "fix" => {
          "active" => false
        },
        "hosts" => [
          {
            "host" => "phx",
            "host_name" => "pardot0-dbshard1-1-phx",
            "is_erroring" => false,
            "is_fixable" => false,
            "lag" => 0
          },
          {
            "host" => "phx2",
            "host_name" => "pardot0-dbshard2-1-phx",
            "is_erroring" => false,
            "is_fixable" => false,
            "lag" => 2
          }
        ],
        "is_erroring" => false,
        "is_fixable" => true
      }

      stub_request(:get, "https://repfix-phx.pardot.com/replication/fixes/for/db/1")
        .and_return(body: JSON.dump(response))

      send_command("status 1")
      expect(replies.last).to eq("status for db-1-phx\n* phx: 0 seconds behind\n* phx2: 2 seconds behind")
    end
  end
end
