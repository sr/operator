require 'ipaddr'

TRUSTED_NETWORKS = [
  '127.0.0.1/32',
  '204.14.236.0/24',    # aloha-east
  '204.14.239.0/24',    # aloha-west
  '62.17.146.140/30',   # aloha-emea
  '62.17.146.144/28',   # aloha-emea
  '62.17.146.160/27',   # aloha-emea
  '173.192.141.222/32', # tools-s1 (prodbot)
  '174.37.191.2/32',    # proxy.dev
  '169.45.0.88/32',     # squid-d4
  '136.147.104.20/30',  # pardot-proxyout1-{1,2,3,4}-dfw
  '136.147.96.20/30',   # pardot-proxyout1-{1,2,3,4}-phx
  '50.22.140.200/32',   # tools-s1.dev

  # https://confluence.dev.pardot.com/pages/viewpage.action?pageId=16001087#AWS/EC2InternalAppsEnvironment-Egress
  '52.72.6.14/32'
]

if Rails.env.development?
  TRUSTED_NETWORKS << '10.0.2.2/32'   # VirtualBox NAT IP
  TRUSTED_NETWORKS << '172.16.0.0/12' # Docker compose instances
end

TRUSTED_NETWORKS.map! { |i| IPAddr.new(i) }
TRUSTED_NETWORKS.freeze

Rack::Attack.whitelist('ip whitelist') do |req|
  remote_ip = IPAddr.new(req.ip)
  req.path == '/_ping' || TRUSTED_NETWORKS.any? { |net| net.include?(remote_ip) }
end

Rack::Attack.blacklist('deny from internet') do |req|
  true
end
