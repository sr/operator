resource "aws_vpc" "pardot_ci" {
  cidr_block = "172.29.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "pardot_ci"
  }
}

resource "aws_subnet" "pardot_ci_us_east_1a" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
  availability_zone = "us-east-1a"
  cidr_block = "172.29.0.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot_ci_us_east_1c" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.29.32.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot_ci_us_east_1d" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.29.64.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot_ci_us_east_1e" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.29.96.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot_ci_us_east_1a_dmz" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
  availability_zone = "us-east-1a"
  cidr_block = "172.29.128.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pardot_ci_us_east_1c_dmz" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.29.160.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pardot_ci_us_east_1d_dmz" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.29.192.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pardot_ci_us_east_1e_dmz" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.29.224.0/19"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "pardot_ci_internet_gw" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
}

resource "aws_eip" "pardot_ci_nat_gw" {
  vpc = true
}

resource "aws_nat_gateway" "pardot_ci_nat_gw" {
  allocation_id = "${aws_eip.pardot_ci_nat_gw.id}"
  subnet_id = "${aws_subnet.pardot_ci_us_east_1a_dmz.id}"
}

resource "aws_route" "pardot_ci_route" {
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.pardot_ci_nat_gw.id}"
}

resource "aws_route_table" "pardot_ci_route_dmz" {
  vpc_id = "${aws_vpc.pardot_ci.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.pardot_ci_internet_gw.id}"
  }
}

resource "aws_route_table_association" "pardot_ci_us_east_1a" {
  subnet_id = "${aws_subnet.pardot_ci_us_east_1a.id}"
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1c" {
  subnet_id = "${aws_subnet.pardot_ci_us_east_1c.id}"
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1d" {
  subnet_id = "${aws_subnet.pardot_ci_us_east_1d.id}"
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1e" {
  subnet_id = "${aws_subnet.pardot_ci_us_east_1e.id}"
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1a_dmz" {
  subnet_id = "${aws_subnet.pardot_ci_us_east_1a_dmz.id}"
  route_table_id = "${aws_route_table.pardot_ci_route_dmz.id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1c_dmz" {
  subnet_id = "${aws_subnet.pardot_ci_us_east_1c_dmz.id}"
  route_table_id = "${aws_route_table.pardot_ci_route_dmz.id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1d_dmz" {
  subnet_id = "${aws_subnet.pardot_ci_us_east_1d_dmz.id}"
  route_table_id = "${aws_route_table.pardot_ci_route_dmz.id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1e_dmz" {
  subnet_id = "${aws_subnet.pardot_ci_us_east_1e_dmz.id}"
  route_table_id = "${aws_route_table.pardot_ci_route_dmz.id}"
}

resource "aws_security_group" "pardot_ci_http_lb" {
  name = "pardot_ci_http_lb"
  description = "Allow HTTP/HTTPS from SFDC VPN only"
  vpc_id = "${aws_vpc.pardot_ci.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "204.14.236.0/24",    # aloha-east
      "204.14.239.0/24",    # aloha-west
      "62.17.146.140/30",   # aloha-emea
      "62.17.146.144/28",   # aloha-emea
      "62.17.146.160/27",   # aloha-emea
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
      "62.17.146.140/30",   # aloha-emea
      "62.17.146.144/28",   # aloha-emea
      "62.17.146.160/27",   # aloha-emea
      "173.192.141.222/32", # tools-s1 (prodbot)
      "174.37.191.2/32",    # proxy.dev
      "169.45.0.88/32",     # squid-d4
      "136.147.104.20/30",  # pardot-proxyout1-{1,2,3,4}-dfw
      "136.147.96.20/30",   # pardot-proxyout1-{1,2,3,4}-phx
      "50.22.140.200/32"    # tools-s1.dev
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "pardot_ci_dc_only_http_lb" {
  name = "pardot_ci_dc_only_http_lb"
  description = "Allow HTTP/HTTPS from SFDC datacenters only"
  vpc_id = "${aws_vpc.pardot_ci.id}"

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

resource "aws_db_subnet_group" "pardot_ci" {
  name = "pardot_ci"
  description = "Pardot CI DB Subnet"
  subnet_ids = [
    "${aws_subnet.pardot_ci_us_east_1a.id}",
    "${aws_subnet.pardot_ci_us_east_1c.id}",
    "${aws_subnet.pardot_ci_us_east_1d.id}",
    "${aws_subnet.pardot_ci_us_east_1e.id}"
  ]
}

# VPC Peering with tools_egress

resource "aws_vpc_peering_connection" "pardot_ci_peer_tools_egress" {
  peer_owner_id = "010094454891" # pardot-atlassian
  peer_vpc_id = "vpc-b64769d2" # tools_egress
  vpc_id = "${aws_vpc.pardot_ci.id}"
}

resource "aws_route" "pardot_ci_route_tools_egress" {
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
  destination_cidr_block = "172.29.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.pardot_ci_peer_tools_egress.id}"
}

# Bastion host

resource "aws_security_group" "pardot_ci_bastion" {
  name = "pardot_ci_bastion"
  description = "Bastion host, allows SSH from SFDC VPNs"
  vpc_id = "${aws_vpc.pardot_ci.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "204.14.236.0/24",    # aloha-east
      "204.14.239.0/24",    # aloha-west
      "62.17.146.140/30",   # aloha-emea
      "62.17.146.144/28",   # aloha-emea
      "62.17.146.160/27"    # aloha-emea
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pardot_ci_bastion" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.small"
  key_name = "pardot_ci"
  subnet_id = "${aws_subnet.pardot_ci_us_east_1a_dmz.id}"
  vpc_security_group_ids = ["${aws_security_group.pardot_ci_bastion.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
    delete_on_termination = false
  }
  tags {
    Name = "pardot0-bastion1-1-ue1"
  }
}

resource "aws_eip" "pardot_ci_bastion" {
  vpc = true
  instance = "${aws_instance.pardot_ci_bastion.id}"
}

resource "aws_instance" "pardot_ci_bastion_2" {
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "t2.small"
  key_name = "pardot_ci"
  subnet_id = "${aws_subnet.pardot_ci_us_east_1d_dmz.id}"
  vpc_security_group_ids = ["${aws_security_group.pardot_ci_bastion.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
    delete_on_termination = false
  }
  tags {
    Name = "pardot0-bastion1-2-ue1"
  }
}

resource "aws_eip" "pardot_ci_bastion_2" {
  vpc = true
  instance = "${aws_instance.pardot_ci_bastion_2.id}"
}
