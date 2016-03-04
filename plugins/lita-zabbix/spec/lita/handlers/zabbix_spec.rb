require "spec_helper"

describe Lita::Handlers::Zabbix, lita_handler: true do
  include ZabbixTestHelpers

  before do
    registry.config.handlers.zabbix.zabbix_url = "https://zabbix-%datacenter%.example/api_jsonrpc.php"
  end

  describe "!zabbix maintenance start" do
    it "puts the host in maintenance for the specified time" do
      stub_api_version
      stub_user_login
      stub_host_get(result: [{"hostid": "12345"}])
      stub_hostgroup_get(result: [{"name": "zMaintenance", "groupid": "99999"}])

      send_command("zabbix maintenance start pardot0-fake1-1-dfw until=+20min")
      expect(replies.last).to match(/^OK, I've added pardot0-fake1-1-dfw.ops.sfdc.net to maintenance until/)
    end
  end

  describe "!zabbix maintenance stop" do
    it "brings the host out of maintenance mode" do
      stub_api_version
      stub_user_login
      stub_host_get(result: [{"hostid": "12345"}])
      stub_hostgroup_get(result: [{"name": "zMaintenance", "groupid": "99999"}])

      send_command("zabbix maintenance stop pardot0-fake1-1-dfw")
      expect(replies.last).to match(/^OK, I've brought pardot0-fake1-1-dfw.ops.sfdc.net out of maintenance/)
    end
  end
end
