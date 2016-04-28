require "spec_helper"

describe Lita::Handlers::Zabbix, lita_handler: true do
  include ZabbixTestHelpers

  before do
    registry.config.handlers.zabbix.zabbix_api_url = "https://zabbix-%datacenter%.example/api_jsonrpc.php"
    registry.config.handlers.zabbix.zabbix_monitor_payload_url= "https://zabbix-%datacenter%.example/cgi-bin/zabbix-status-check.sh?"
    registry.config.handlers.zabbix.active_monitors = [::Zabbix::Zabbixmon::MONITOR_NAME]
    registry.config.handlers.zabbix.paging_monitors = [::Zabbix::Zabbixmon::MONITOR_NAME]
    registry.config.handlers.zabbix.pager = 'pagerduty'
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

  describe "!zabbix monitor pause" do
    it "pauses the monitor for the specified time" do
      stub_api_version
      stub_user_login
      send_command("zabbix monitor dfw pause until=7d")
      expect(replies.last).to match(/^.*OK, I've paused zabbixmon for the dfw datacenter until.*$/)
    end
  end

  describe "!zabbix monitor unpause" do
    it "unpauses the monitor" do
      stub_api_version
      stub_user_login
      send_command("zabbix monitor dfw unpause")
      expect(replies.last).to match(/^.*OK, I've unpaused zabbixmon for datacenter dfw\. Monitoring will resume\.$/)
    end
  end

  describe "!zabbix monitor status" do
    it "shows the proper status" do
      stub_api_version
      stub_user_login
      send_command("zabbix monitor status")
      expect(replies.last).to match(/^.*zabbixmon.*active.*pagerduty.*$/)
    end
  end

  # describe "!zabbix monitor run dfw" do
  #   it "successfully completes manually_run_monitor('dfw')" do
  #     stub_user_login
  #     stub_insert_payload
  #     stub_item_get(result: [ { fake_item_key: "fake item value" } ] )
  #     send_command("zabbix monitor run dfw")
  #     expect(replies.last).to match(/^.*is confirmed alive*$/)
  #   end
  # end
end