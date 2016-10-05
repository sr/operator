variable "aloha_vpn_cidr_blocks" {
  type = "list"
  default = [
    "204.14.236.0/24",  # aloha-east
    "204.14.239.0/24",  # aloha-west
    "62.17.146.140/30", # aloha-emea
    "62.17.146.144/28", # aloha-emea
    "62.17.146.160/27"  # aloha-emea
  ]
}

variable "sfdc_proxyout_cidr_blocks" {
  type = "list"
  default = [
    "136.147.104.20/30", # pardot0-proxyout1-{1,2,3,4}-dfw
    "136.147.96.20/30",  # pardot0-proxyout1-{1,2,3,4}-phx
    "136.147.104.40/30", # pardot1-proxyout1-{1,2}-dfw
    "136.147.96.40/30"   # pardot1-proxyout1-{1,2}-phx
  ]
}

variable "pardot_ci_vpc_cidr" {
  default = "172.27.0.0/16"
}
