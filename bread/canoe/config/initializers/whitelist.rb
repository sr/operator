require "ipaddr"

trusted_networks = [
  "127.0.0.1/32",
  "204.14.236.0/24",    # amer east
  "204.14.239.0/24",    # amer west
  "62.17.146.140/30",   # EMEA 62.17.146.140 - 62.17.146.143
  "62.17.146.144/28",   # EMEA 62.17.146.144 - 62.17.146.159
  "62.17.146.160/28",   # EMEA 62.17.146.160 - 62.17.146.175
  "62.17.146.176/28",   # EMEA 62.17.146.176 - 62.17.146.191
  "202.95.77.64/27",    # APAC Singapore
  "221.133.209.128/27", # APAC Sydney
  "142.176.79.170/29",  # Halifax, Canada
  "61.120.150.128/27",  # Tokyo, Japan
  "61.213.161.144/30",  # Tokyo, Japan
  "136.147.104.42/32",  # pardot1-proxyout1-1-dfw (OUTBOUND NAT)
  "136.147.104.20/30",  # pardot0-proxyout1-{1,2,3,4}-dfw
  "136.147.96.20/30",   # pardot0-proxyout1-{1,2,3,4}-phx
  "52.205.208.100/32",  # pardot0-ue1
  "54.82.15.10/32",     # Ditto, but for App.dev
  "34.192.47.206/32",   # Heroku: Netherworld
  "34.192.147.59/32",   # Heroku: Netherworld
  "34.192.142.55/32",   # Heroku: Netherworld
  "34.192.58.27/32",    # Heroku: Netherworld
  "52.70.38.185/32",    # Heroku: Production
  "52.3.60.97/32",      # Heroku: Production
  "54.82.52.167/32",    # Heroku: Production
  "54.82.76.144/32"     # Heroku: Production
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