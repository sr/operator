module ZabbixTestHelpers
  def stub_api_version(url: "https://zabbix-dfw.example/api_jsonrpc.php", version: "2.4.6")
    stub_request(:post, url)
      .with(:body => /"method":"apiinfo.version"/)
      .to_return(:status => 200, :body => JSON.dump("jsonrpc": "2.0", "result": version))
  end

  def stub_user_login(url: "https://zabbix-dfw.example/api_jsonrpc.php", result: "abc123")
    stub_request(:post, url)
      .with(:body => /"method":"user.login"/)
      .to_return(:status => 200, :body => JSON.dump("jsonrpc": "2.0", "result": result))
  end

  def stub_host_get(url: "https://zabbix-dfw.example/api_jsonrpc.php", result: [])
    stub_request(:post, url)
      .with(:body => /"method":"host.get"/)
      .to_return(:status => 200, :body => JSON.dump("jsonrpc": "2.0", "result": result))
  end

  def stub_hostgroup_get(url: "https://zabbix-dfw.example/api_jsonrpc.php", result: [])
    stub_request(:post, url)
      .with(:body => /"method":"hostgroup.get"/)
      .to_return(:status => 200, :body => JSON.dump("jsonrpc": "2.0", "result": result))
  end

  def stub_host_update(url: "https://zabbix-dfw.example/api_jsonrpc.php", result: [])
    stub_request(:post, url)
      .with(:body => /"method":"host.update"/)
      .to_return(:status => 200, :body => JSON.dump("jsonrpc": "2.0", "result": result))
  end

  # def stub_insert_payload(url: "https://zabbix-dfw.example/cgi-bin/zabbix-status-check.sh?", result: [], payload: "BR34D")
  #   stub_request(:get, "#{url}#{payload}")
  #       .to_return(:status => 200)
  # end
  #
  # def stub_item_get(url: "https://zabbix-dfw.example/api_jsonrpc.php", result: [])
  #   stub_request(:post, url)
  #       .with(:body => /"method":"item.get"/)
  #       .to_return(:status => 200, :body => JSON.dump("jsonrpc": "2.0", "result": result))
  # end
end
