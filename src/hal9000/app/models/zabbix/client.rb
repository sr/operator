require "set"

module Zabbix
  class Client
    HostNotFound = Class.new(StandardError)
    MaintenanceGroupDoesNotExist = Class.new(StandardError)

    MAINTENANCE_GROUP_NAME = "zMaintenance".freeze

    def initialize(url:, user:, password:)
      @client = ZabbixApi.connect(
        url: url,
        user: user,
        password: password,
      )
    end

    def ensure_host_in_zabbix_maintenance_group(host)
      group_ids = Set.new(host.fetch("groups").map { |g| g["groupid"] })
      group_ids.add(maintenance_group_id)

      @client.hosts.update(
        host: host["host"],
        hostid: host["hostid"],
        groups: group_ids.map { |id| { "groupid" => id } },
      )
    end

    def ensure_host_not_in_zabbix_maintenance_group(host)
      group_ids = Set.new(host.fetch("groups").map { |g| g["groupid"] })
      group_ids.delete(maintenance_group_id)

      @client.hosts.update(
        host: host["host"],
        hostid: host["hostid"],
        groups: group_ids.map { |id| { "groupid" => id } },
      )
    end

    def get_host(hostname)
      @client.client.api_request(
        method: "host.get",
        params: {
          output: "extend",
          selectGroups: "extend",
          filter: {
            host: hostname
          }
        },
      ).first.tap do |host|
        raise HostNotFound if host.nil?
      end
    end

    def search_hosts(host_glob)
      @client.client.api_request(
        method: "host.get",
        params: {
          output: "extend",
          selectGroups: "extend",
          search: {
            host: host_glob
          },
          searchWildcardsEnabled: 1
        }
      )
    end

    def get_item_by_name_and_lastvalue(name, lastvalue)
      @client.items.get(name: name, lastvalue: lastvalue) unless name.nil? || lastvalue.nil?
    end

    private

    def maintenance_group_id
      @client.hostgroups.get_id(name: MAINTENANCE_GROUP_NAME).tap { |group_id|
        raise MaintenanceGroupDoesNotExist, "Could not find ID for hostgroup #{MAINTENANCE_GROUP_NAME}" if group_id.nil?
      }.to_s
    end
  end
end