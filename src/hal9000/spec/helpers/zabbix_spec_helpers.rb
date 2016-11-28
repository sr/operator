require "date"

module ZabbixSpecHelpers
  def stub_api_version(url: /https:\/\/zabbix.*\.pardot.com\/api_jsonrpc.php/, version: "2.4.6")
    stub_request(:post, url)
      .with(body: /"method":"apiinfo.version"/)
      .to_return(status: 200, body: JSON.dump("jsonrpc": "2.0", "result": version))
  end

  def stub_user_login(url: /https:\/\/zabbix.*\.pardot.com\/api_jsonrpc.php/, result: "abc123")
    stub_request(:post, url)
      .with(body: /"method":"user.login"/)
      .to_return(status: 200, body: JSON.dump("jsonrpc": "2.0", "result": result))
  end

  def stub_host_get(url: /https:\/\/zabbix.*\.pardot.com\/api_jsonrpc.php/, result: [])
    stub_request(:post, url)
      .with(body: /"method":"host.get"/)
      .to_return(status: 200, body: JSON.dump("jsonrpc": "2.0", "result": result))
  end

  def stub_hostgroup_get(url: /https:\/\/zabbix.*\.pardot.com\/api_jsonrpc.php/, result: [])
    stub_request(:post, url)
      .with(body: /"method":"hostgroup.get"/)
      .to_return(status: 200, body: JSON.dump("jsonrpc": "2.0", "result": result))
  end

  def stub_host_update(url: /https:\/\/zabbix.*\.pardot.com\/api_jsonrpc.php/, result: [])
    stub_request(:post, url)
      .with(body: /"method":"host.update"/)
      .to_return(status: 200, body: JSON.dump("jsonrpc": "2.0", "result": result))
  end

  def stub_insert_payload(url: /zabbix.*\.pardot.com\/cgi-bin\/zabbix-status-check\.sh\?.*/, result: [])
    stub_request(:get, url)
        .to_return(status: 200, body: "", headers: {})
  end

  def stub_item_get(url: /https:\/\/zabbix.*\.pardot.com\/api_jsonrpc.php/, result: [])
    stub_request(:post, url)
        .with(body: /"method":"item.get"/)
        .to_return(status: 200, body: JSON.dump("jsonrpc": "2.0", "result": result))
  end

  def stub_page_pagerduty(url: /.*events\.pagerduty\.com\/generic\/.*\/create_event\.json.*/, result: [])
    stub_request(:post, url)
        .with(body: "{\"incident_key\":\"zabbixmon-test\",\"description\":\"This is a test of the ZabbixMon pager. Please dismiss and ignore.\",\"service_key\":null,\"event_type\":\"trigger\"}",
             headers: { "Accept" => "*/*", "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3" })
        .to_return(status: 200, body: "", headers: {})
  end
end
