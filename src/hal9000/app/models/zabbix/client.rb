require "set"

module Zabbix
  class Client
    HostNotFound = Class.new(StandardError)
    MaintenanceGroupDoesNotExist = Class.new(StandardError)

    MAINTENANCE_GROUP_NAME = "zMaintenance".freeze

    def initialize(url:, user:, password:)
      orig_http_proxy = ENV["http_proxy"]
      ENV["http_proxy"] = ENV.fetch("HAL9000_HTTP_PROXY", nil)
      @client = ZabbixApi.connect(
        url: url,
        user: user,
        password: password,
      )
    ensure
      ENV["http_proxy"] = orig_http_proxy
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

    def get_problem_triggers_by_app_name(app_name)
      app_ids = @client.query(
        method: "application.get",
        params: {
          putput: "extend",
          filter: {
            name: app_name
          }
        }
      ).map { |a| a["applicationid"] }

      @client.query(
        method: "trigger.get",
        params: {
          output: "extend",
          selectHosts: "extend",
          expandDescription: true,
          active: true,
          monitored: true,
          applicationids: app_ids,
          sortfield: "hostname",
          filter: {
            value: 1 # problem
          }
        }
      )
    end

    # Fetches hosts without data for given application name. This is necessary
    # to catch hosts that aren't reporting data at all, possibly because Chef
    # hasn't run. In Zabbix >= 3.2, a function like this will not be necessary
    # because functions like `nodata` will work correctly on unsupported items.
    def get_hosts_without_item_data_by_app_name(app_name)
      results = @client.query(
        method: "item.get",
        params: {
          output: "extend",
          selectHosts: "extend",
          application: app_name,
          monitored: true,
          filter: {
            showWithoutData: 1
          }
        }
      )

      results.select { |result| result["lastclock"] == "0" } # no data
        .flat_map { |result| result["hosts"] }
        .select { |host| host["maintenance_status"] == "0" } # not in maintenance
        .uniq { |host| host["hostid"] }
        .sort_by { |host| host["host"] }
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
