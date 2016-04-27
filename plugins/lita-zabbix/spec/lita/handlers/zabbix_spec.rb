require "spec_helper"

describe Lita::Handlers::Zabbix, lita_handler: true do
  include ZabbixTestHelpers

  before do
    registry.config.handlers.zabbix.zabbix_api_url = "https://zabbix-%datacenter%.example/api_jsonrpc.php"
  end

  describe "!zabbix maintenance start" do
    it "puts the host in maintenance for the specified time" do
      stub_api_version
      stub_user_login
      stub_host_get(result: [{"hostid": "12345", "host": "pardot0-fake1-1-dfw.ops.sfdc.net", "groups":[{"groupid": "1234"}]}])
      stub_hostgroup_get(result: [{"name": "zMaintenance", "groupid": "99999"}])
      stub_host_update

      send_command("zabbix maintenance start pardot0-fake1-1-dfw* until=+20min")
      expect(replies.last).to match(/^OK, I've started maintenance on pardot0-fake1-1-dfw\* \(matched 1 hosts\) until/)
    end
  end

  describe "!zabbix maintenance stop" do
    it "brings the host out of maintenance mode" do
      stub_api_version
      stub_user_login
      stub_host_get(result: [{"hostid": "12345", "host": "pardot0-fake1-1-dfw.ops.sfdc.net", "groups":[{"groupid": "1234"}]}])
      stub_hostgroup_get(result: [{"name": "zMaintenance", "groupid": "99999"}])
      stub_host_update

      send_command("zabbix maintenance stop pardot0-fake1-1-dfw*")
      expect(replies.last).to match(/^OK, I've stopped maintenance on pardot0-fake1-1-dfw\* \(matched 1 hosts\)/)
    end
  end
end

describe "!zabbix monitor pause" do
  it "puts the monitor for the specified time" do
    stub_api_version
    stub_user_login
    stub_host_get(result: [{"hostid": "12345", "host": "pardot0-fake1-1-dfw.ops.sfdc.net", "groups":[{"groupid": "1234"}]}])
    stub_hostgroup_get(result: [{"name": "zMaintenance", "groupid": "99999"}])
    stub_host_update

    send_command("zabbix maintenance start pardot0-fake1-1-dfw* until=+20min")
    expect(replies.last).to match(/^OK, I've started maintenance on pardot0-fake1-1-dfw\* \(matched 1 hosts\) until/)
  end
end

describe "!zabbix monitor unpause" do
  it "brings the host out of maintenance mode" do
    stub_api_version
    stub_user_login
    stub_host_get(result: [{"hostid": "12345", "host": "pardot0-fake1-1-dfw.ops.sfdc.net", "groups":[{"groupid": "1234"}]}])
    stub_hostgroup_get(result: [{"name": "zMaintenance", "groupid": "99999"}])
    stub_host_update

    send_command("zabbix maintenance stop pardot0-fake1-1-dfw*")
    expect(replies.last).to match(/^OK, I've stopped maintenance on pardot0-fake1-1-dfw\* \(matched 1 hosts\)/)
  end
end
end
