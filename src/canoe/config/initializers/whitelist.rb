require "ipaddr"

trusted_networks = [
  "127.0.0.1/32",
  "204.14.236.0/24",    # aloha-east
  "204.14.239.0/24",    # aloha-west
  "62.17.146.140/30",   # aloha-emea
  "62.17.146.144/28",   # aloha-emea
  "62.17.146.160/27",   # aloha-emea
  "136.147.104.20/30",  # pardot-proxyout1-{1,2,3,4}-dfw
  "136.147.96.20/30",   # pardot-proxyout1-{1,2,3,4}-phx
  # https://confluence.dev.pardot.com/pages/viewpage.action?pageId=16001087#AWS/EC2InternalAppsEnvironment-Egress
  "52.72.6.14/32",
  # Ditto, but for App.dev
  "54.82.15.10/32"
]

if Rails.env.development?
  trusted_networks << "10.0.2.2/32"   # VirtualBox NAT IP
  trusted_networks << "172.16.0.0/12" # Docker compose instances
end

trusted_networks = trusted_networks.map { |i| IPAddr.new(i) }
trusted_networks.freeze

Rack::Attack.whitelist("ip whitelist") do |req|
  remote_ip = IPAddr.new(req.ip)
  req.path == "/_ping" || trusted_networks.any? { |net| net.include?(remote_ip) }
end

Rack::Attack.blacklist("deny from internet") do |_req|
  true
end
