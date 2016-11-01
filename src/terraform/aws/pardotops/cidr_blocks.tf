variable "aloha_vpn_cidr_blocks" {
  type = "list"

  default = [
    "204.14.236.0/24",  # aloha-east
    "204.14.239.0/24",  # aloha-west
    "62.17.146.140/30", # aloha-emea
    "62.17.146.144/28", # aloha-emea
    "62.17.146.160/27", # aloha-emea
  ]
}

variable "sfdc_proxyout_cidr_blocks" {
  type = "list"

  default = [
    "136.147.104.20/30", # pardot0-proxyout1-{1,2,3,4}-dfw
    "136.147.96.20/30",  # pardot0-proxyout1-{1,2,3,4}-phx
    "136.147.104.40/30", # pardot1-proxyout1-{1,2}-dfw
    "136.147.96.40/30",  # pardot1-proxyout1-{1,2}-phx
  ]
}

variable "pardot_ci_vpc_cidr" {
  default = "172.27.0.0/16"
}

variable "sfdc_org62_sandbox_cidr_blocks" {
  type = "list"

  default = [
    "13.108.0.0/14",    # CS46 POD - Org62QA1 sandbox subnet1
    "96.43.144.0/20",   # CS46 POD - Org62QA1 sandbox subnet2
    "136.146.0.0/15",   # CS46 POD - Org62QA1 sandbox subnet3
    "204.14.232.0/21",  # CS46 POD - Org62QA1 sandbox subnet4
    "85.222.128.0/19",  # CS46 POD - Org62QA1 sandbox subnet5
    "185.79.140.0/22",  # CS46 POD - Org62QA1 sandbox subnet6
    "101.53.160.0/19",  # CS46 POD - Org62QA1 sandbox subnet7
    "182.50.76.0/22",   # CS46 POD - Org62QA1 sandbox subnet8
    "202.129.242.0/23", # CS46 POD - Org62QA1 sandbox subnet9
  ]
}
