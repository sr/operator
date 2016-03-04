require "spec_helper"

describe Lita::Handlers::Zabbix, lita_handler: true do
  include ZabbixTestHelpers

  before do
    registry.config.handlers.zabbix.zabbix_url = "https://zabbix-%datacenter%.example/api_jsonrpc.php"
  end

  describe "!zabbix maintenance set" do
    it "sets the host in maintenance for the specified time" do
      stub_api_version
      stub_user_login
      stub_host_get(result: [{"hostid": "12345"}])
      stub_hostgroup_get(result: [{"name": "zMaintenance", "groupid": "99999"}])

      send_command("zabbix maintenance set pardot0-fake1-1-dfw until=+20min")
      expect(replies.last).to match(/^OK, I've added pardot0-fake1-1-dfw.ops.sfdc.net to maintenance until/)
    end
  end
end
