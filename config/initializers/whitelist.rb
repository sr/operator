require 'ipaddr'

TRUSTED_NETWORKS = [
  '127.0.0.1/32',
  '204.14.236.0/24', # aloha-east
  '204.14.239.0/24'  # aloha-west
].map { |i| IPAddr.new(i) }.freeze

Rack::Attack.whitelist('allow from localhost') do |req|
  remote_ip = IPAddr.new(req.ip)
  TRUSTED_NETWORKS.any? { |net| net.include?(remote_ip) }
end
