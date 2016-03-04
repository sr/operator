require "set"

module Zabbix
  class Client
    HostNotFound = Class.new(StandardError)
    MaintenanceGroupDoesNotExist = Class.new(StandardError)

    MAINTENANCE_GROUP_NAME = "zMaintenance"

    def initialize(url:, user:, password:)
      @client = ZabbixApi.connect(
        url: url,
        user: user,
        password: password,
      )
    end

    def ensure_host_in_zabbix_maintenance_group(host)
      data = host_full_data_with_groups(host)

      group_ids = Set.new(data.fetch("groups", []).map { |g| g["groupid"] })
      group_ids.add(maintenance_group_id)

      @client.hosts.update(
        host: host,
        hostid: data["hostid"],
        groups: group_ids.map { |id| {"groupid" => id} },
      )
    end

    def ensure_host_not_in_zabbix_maintenance_group(host)
      data = host_full_data_with_groups(host)

      group_ids = Set.new(data.fetch("groups", []).map { |g| g["groupid"] })
      group_ids.delete(maintenance_group_id)

      @client.hosts.update(
        host: host,
        hostid: data["hostid"],
        groups: group_ids.map { |id| {"groupid" => id} },
      )
    end

    def host_full_data_with_groups(host)
      data = @client.client.api_request(
        method: "host.get",
        params: {
          filter: {
            host: host,
          },
          output: "extend",
          selectGroups: "extend",
        }
      ).first

      raise HostNotFound, "Host not found: #{host}" if data.nil?
      data
    end

    def maintenance_group_id
      @client.hostgroups.get_id(name: MAINTENANCE_GROUP_NAME).tap { |group_id|
        raise MaintenanceGroupDoesNotExist, "Could not find ID for hostgroup #{MAINTENANCE_GROUP_NAME}" if group_id.nil?
      }.to_s
    end
  end
end
