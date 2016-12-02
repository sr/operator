variable "aloha_vpn_cidr_blocks" {
  type = "list"

  default = [
    "204.14.236.0/24",    # amer east
    "204.14.239.0/24",    # amer west
    "62.17.146.140/30",   # EMEA 62.17.146.140 - 62.17.146.143
    "62.17.146.144/28",   # EMEA 62.17.146.144 - 62.17.146.159
    "62.17.146.160/28",   # EMEA 62.17.146.160 - 62.17.146.175
    "62.17.146.176/28",   # EMEA 62.17.146.176 - 62.17.146.191
    "202.95.77.64/27",    # APAC Singapore
    "221.133.209.128/27", # APAC Sydney
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

variable "sfdc_pardot_tools_production_heroku_space_cidr_blocks" {
  type = "list"

  default = [
    "52.70.38.185/32",
    "52.3.60.97/32",
    "54.82.52.167/32",
    "54.82.76.144/32",
  ]
}

variable "pardot_ci_vpc_cidr" {
  default = "172.27.0.0/16"
}

# https://help.salesforce.com/apex/HTViewSolution?id=000003652
variable "salesforce_cidr_blocks" {
  type = "list"

  default = [
    "13.108.0.0/14",
    "96.43.144.0/20",
    "136.146.0.0/15",
    "204.14.232.0/21",
    "85.222.128.0/19",
    "185.79.140.0/22",
    "101.53.160.0/19",
    "182.50.76.0/22",
    "202.129.242.0/23",
  ]
}
