resource "aws_vpc" "internal_apps" {
  cidr_block = "172.30.0.0/16"
  tags {
    Name = "internal_apps"
  }
}

resource "aws_security_group_rule" "internal_apps_allow_internal_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${aws_vpc.internal_apps.default_security_group_id}"
  cidr_blocks = ["${aws_vpc.internal_apps.cidr_block}"]
}

resource "aws_security_group_rule" "internal_apps_allow_internal_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = "${aws_vpc.internal_apps.default_security_group_id}"
  cidr_blocks = ["${aws_vpc.internal_apps.cidr_block}"]
}

resource "aws_subnet" "internal_apps_us_east_1a" {
  vpc_id = "${aws_vpc.internal_apps.id}"
  availability_zone = "us-east-1a"
  cidr_block = "172.30.0.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "internal_apps_us_east_1c" {
  vpc_id = "${aws_vpc.internal_apps.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.30.32.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "internal_apps_us_east_1d" {
  vpc_id = "${aws_vpc.internal_apps.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.30.64.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "internal_apps_us_east_1e" {
  vpc_id = "${aws_vpc.internal_apps.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.30.96.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "internal_apps_us_east_1a_dmz" {
  vpc_id = "${aws_vpc.internal_apps.id}"
  availability_zone = "us-east-1a"
  cidr_block = "172.30.128.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "internal_apps_us_east_1c_dmz" {
  vpc_id = "${aws_vpc.internal_apps.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.30.160.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "internal_apps_us_east_1d_dmz" {
  vpc_id = "${aws_vpc.internal_apps.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.30.192.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "internal_apps_us_east_1e_dmz" {
  vpc_id = "${aws_vpc.internal_apps.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.30.224.0/19"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "internal_apps_internet_gw" {
  vpc_id = "${aws_vpc.internal_apps.id}"
}

resource "aws_eip" "internal_apps_nat_gw" {
  vpc = true
}

resource "aws_nat_gateway" "internal_apps_nat_gw" {
  allocation_id = "${aws_eip.internal_apps_nat_gw.id}"
  subnet_id = "${aws_subnet.internal_apps_us_east_1a_dmz.id}"
}

resource "aws_route" "internal_apps_route" {
  route_table_id = "${aws_vpc.internal_apps.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.internal_apps_nat_gw.id}"
}

resource "aws_route_table" "internal_apps_route_dmz" {
  vpc_id = "${aws_vpc.internal_apps.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internal_apps_internet_gw.id}"
  }
}

resource "aws_route_table_association" "internal_apps_us_east_1a" {
  subnet_id = "${aws_subnet.internal_apps_us_east_1a.id}"
  route_table_id = "${aws_vpc.internal_apps.main_route_table_id}"
}

resource "aws_route_table_association" "internal_apps_us_east_1c" {
  subnet_id = "${aws_subnet.internal_apps_us_east_1c.id}"
  route_table_id = "${aws_vpc.internal_apps.main_route_table_id}"
}

resource "aws_route_table_association" "internal_apps_us_east_1d" {
  subnet_id = "${aws_subnet.internal_apps_us_east_1d.id}"
  route_table_id = "${aws_vpc.internal_apps.main_route_table_id}"
}

resource "aws_route_table_association" "internal_apps_us_east_1e" {
  subnet_id = "${aws_subnet.internal_apps_us_east_1e.id}"
  route_table_id = "${aws_vpc.internal_apps.main_route_table_id}"
}

resource "aws_route_table_association" "internal_apps_us_east_1a_dmz" {
  subnet_id = "${aws_subnet.internal_apps_us_east_1a_dmz.id}"
  route_table_id = "${aws_route_table.internal_apps_route_dmz.id}"
}

resource "aws_route_table_association" "internal_apps_us_east_1c_dmz" {
  subnet_id = "${aws_subnet.internal_apps_us_east_1c_dmz.id}"
  route_table_id = "${aws_route_table.internal_apps_route_dmz.id}"
}

resource "aws_route_table_association" "internal_apps_us_east_1d_dmz" {
  subnet_id = "${aws_subnet.internal_apps_us_east_1d_dmz.id}"
  route_table_id = "${aws_route_table.internal_apps_route_dmz.id}"
}

resource "aws_route_table_association" "internal_apps_us_east_1e_dmz" {
  subnet_id = "${aws_subnet.internal_apps_us_east_1e_dmz.id}"
  route_table_id = "${aws_route_table.internal_apps_route_dmz.id}"
}

resource "aws_security_group" "internal_apps_http_lb" {
  name = "internal_apps_http_lb"
  description = "Allow HTTP/HTTPS from SFDC VPN only"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "204.14.236.0/24",    # aloha-east
      "204.14.239.0/24",    # aloha-west
      "173.192.141.222/32", # tools-s1 (prodbot)
      "174.37.191.2/32",    # proxy.dev
      "169.45.0.88/32",     # squid-d4
      "136.147.104.20/30",  # pardot-proxyout1-{1,2,3,4}-dfw
      "136.147.96.20/30"    # pardot-proxyout1-{1,2,3,4}-phx
    ]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "204.14.236.0/24",    # aloha-east
      "204.14.239.0/24",    # aloha-west
      "173.192.141.222/32", # tools-s1 (prodbot)
      "174.37.191.2/32",    # proxy.dev
      "169.45.0.88/32",     # squid-d4
      "136.147.104.20/30",  # pardot-proxyout1-{1,2,3,4}-dfw
      "136.147.96.20/30"    # pardot-proxyout1-{1,2,3,4}-phx
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "internal_apps_dc_only_http_lb" {
  name = "internal_apps_dc_only_http_lb"
  description = "Allow HTTP/HTTPS from SFDC datacenters only"
  vpc_id = "${aws_vpc.internal_apps.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "173.192.141.222/32", # tools-s1 (prodbot)
      "174.37.191.2/32",    # proxy.dev
      "169.45.0.88/32",     # squid-d4
      "136.147.104.20/30",  # pardot-proxyout1-{1,2,3,4}-dfw
      "136.147.96.20/30"    # pardot-proxyout1-{1,2,3,4}-phx
    ]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "173.192.141.222/32", # tools-s1 (prodbot)
      "208.43.203.134/32",  # email-d1 (replication check)
      "174.37.191.2/32",    # proxy.dev
      "169.45.0.88/32",     # squid-d4
      "136.147.104.20/30",  # pardot-proxyout1-{1,2,3,4}-dfw
      "136.147.96.20/30"    # pardot-proxyout1-{1,2,3,4}-phx
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "internal_apps_allow_lb_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = "${aws_vpc.internal_apps.default_security_group_id}"
  source_security_group_id = "${aws_security_group.internal_apps_http_lb.id}"
}

resource "aws_db_subnet_group" "internal_apps" {
  name = "internal_apps"
  description = "Internal Apps DB Subnet"
  subnet_ids = [
    "${aws_subnet.internal_apps_us_east_1a.id}",
    "${aws_subnet.internal_apps_us_east_1c.id}",
    "${aws_subnet.internal_apps_us_east_1d.id}",
    "${aws_subnet.internal_apps_us_east_1e.id}"
  ]
}
