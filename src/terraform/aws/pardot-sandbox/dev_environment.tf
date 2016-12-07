resource "aws_vpc" "dev_environment" {
  cidr_block = "172.30.0.0/16"

  tags {
    Name = "dev_environment"
  }
}

resource "aws_security_group_rule" "dev_environment_allow_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_vpc.dev_environment.default_security_group_id}"

  cidr_blocks = [
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
  ]
}

resource "aws_security_group_rule" "dev_environment_allow_vpn_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_vpc.dev_environment.default_security_group_id}"

  cidr_blocks = [
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
  ]
}

resource "aws_security_group_rule" "dev_environment_allow_vpn_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_vpc.dev_environment.default_security_group_id}"

  cidr_blocks = [
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
  ]
}

resource "aws_security_group" "allow_inbound_http_https_from_sfdc" {
  name   = "allow_inbound_http_https_from_sfdc"
  vpc_id = "${aws_vpc.dev_environment.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# https://help.salesforce.com/apex/HTViewSolution?id=000003652
resource "aws_security_group_rule" "dev_environment_allow_salesforce_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.allow_inbound_http_https_from_sfdc.id}"

  cidr_blocks = [
    "13.108.0.0/14",
    "96.43.144.0/20",
    "136.146.0.0/15",
    "204.14.232.0/21",
  ]
}

# https://help.salesforce.com/apex/HTViewSolution?id=000003652
resource "aws_security_group_rule" "dev_environment_allow_salesforce_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.allow_inbound_http_https_from_sfdc.id}"

  cidr_blocks = [
    "13.108.0.0/14",
    "96.43.144.0/20",
    "136.146.0.0/15",
    "204.14.232.0/21",
  ]
}

resource "aws_subnet" "dev_environment_us_east_1b" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1b"
  cidr_block              = "172.30.0.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1c" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.30.32.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1d" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1d"
  cidr_block              = "172.30.64.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1e" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.30.96.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1b_dmz" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1b"
  cidr_block              = "172.30.128.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1c_dmz" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.30.160.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1d_dmz" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1d"
  cidr_block              = "172.30.192.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev_environment_us_east_1e_dmz" {
  vpc_id                  = "${aws_vpc.dev_environment.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.30.224.0/19"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "dev_environment_internet_gw" {
  vpc_id = "${aws_vpc.dev_environment.id}"
}

resource "aws_eip" "dev_environment_nat_gw" {
  vpc = true
}

resource "aws_nat_gateway" "dev_environment_nat_gw" {
  allocation_id = "${aws_eip.dev_environment_nat_gw.id}"
  subnet_id     = "${aws_subnet.dev_environment_us_east_1b_dmz.id}"
}

# All Artifactory requests get NATed so the source IP is constant
resource "aws_route" "dev_environment_artifactory_route" {
  route_table_id         = "${aws_vpc.dev_environment.main_route_table_id}"
  destination_cidr_block = "${var.legacy_artifactory_instance_ip}/32"       # artifactory.dev.pardot.com
  nat_gateway_id         = "${aws_nat_gateway.dev_environment_nat_gw.id}"
}

resource "aws_route" "dev_environment_internet_route" {
  route_table_id         = "${aws_vpc.dev_environment.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.dev_environment_internet_gw.id}"
}

resource "aws_route_table" "dev_environment_route_dmz" {
  vpc_id = "${aws_vpc.dev_environment.id}"
}

resource "aws_route" "dev_environment_dmz_internet_route" {
  route_table_id         = "${aws_route_table.dev_environment_route_dmz.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.dev_environment_internet_gw.id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1b" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1b.id}"
  route_table_id = "${aws_vpc.dev_environment.main_route_table_id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1c" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1c.id}"
  route_table_id = "${aws_vpc.dev_environment.main_route_table_id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1d" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1d.id}"
  route_table_id = "${aws_vpc.dev_environment.main_route_table_id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1e" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1e.id}"
  route_table_id = "${aws_vpc.dev_environment.main_route_table_id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1b_dmz" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1b_dmz.id}"
  route_table_id = "${aws_route_table.dev_environment_route_dmz.id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1c_dmz" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1c_dmz.id}"
  route_table_id = "${aws_route_table.dev_environment_route_dmz.id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1d_dmz" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1d_dmz.id}"
  route_table_id = "${aws_route_table.dev_environment_route_dmz.id}"
}

resource "aws_route_table_association" "dev_environment_us_east_1e_dmz" {
  subnet_id      = "${aws_subnet.dev_environment_us_east_1e_dmz.id}"
  route_table_id = "${aws_route_table.dev_environment_route_dmz.id}"
}

resource "aws_route53_zone" "pardot_local" {
  name   = "pardot.local"
  vpc_id = "${aws_vpc.dev_environment.id}"
}

resource "aws_route53_record" "star_pardot_local" {
  zone_id = "${aws_route53_zone.pardot_local.zone_id}"
  name    = "*.pardot.local"
  type    = "A"
  records = ["127.0.0.1"]
  ttl     = "3600"
}
