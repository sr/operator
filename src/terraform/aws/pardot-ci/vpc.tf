resource "aws_vpc" "pardot_ci" {
  cidr_block           = "172.27.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "pardot_ci"
  }
}

resource "aws_subnet" "pardot_ci_us_east_1a" {
  vpc_id                  = "${aws_vpc.pardot_ci.id}"
  availability_zone       = "us-east-1a"
  cidr_block              = "172.27.0.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot_ci_us_east_1c" {
  vpc_id                  = "${aws_vpc.pardot_ci.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.27.32.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot_ci_us_east_1b" {
  vpc_id                  = "${aws_vpc.pardot_ci.id}"
  availability_zone       = "us-east-1b"
  cidr_block              = "172.27.64.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot_ci_us_east_1e" {
  vpc_id                  = "${aws_vpc.pardot_ci.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.27.96.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot_ci_us_east_1a_dmz" {
  vpc_id                  = "${aws_vpc.pardot_ci.id}"
  availability_zone       = "us-east-1a"
  cidr_block              = "172.27.128.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pardot_ci_us_east_1c_dmz" {
  vpc_id                  = "${aws_vpc.pardot_ci.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.27.160.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pardot_ci_us_east_1b_dmz" {
  vpc_id                  = "${aws_vpc.pardot_ci.id}"
  availability_zone       = "us-east-1b"
  cidr_block              = "172.27.192.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pardot_ci_us_east_1e_dmz" {
  vpc_id                  = "${aws_vpc.pardot_ci.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.27.224.0/19"
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
  subnet_id     = "${aws_subnet.pardot_ci_us_east_1a_dmz.id}"
}

resource "aws_route" "pardot_ci_route" {
  route_table_id         = "${aws_vpc.pardot_ci.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.pardot_ci_nat_gw.id}"
}

resource "aws_route_table" "pardot_ci_route_dmz" {
  vpc_id = "${aws_vpc.pardot_ci.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.pardot_ci_internet_gw.id}"
  }

  route {
    cidr_block                = "172.31.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.pardot_atlassian_tools_and_pardot_ci_vpc_peering.id}"
  }

  route {
    cidr_block                = "172.26.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.pardotops_appdev_and_pardot_ci_vpc_peering.id}"
  }
}

resource "aws_route" "pardot_ci_to_atlassian_tools" {
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.pardot_atlassian_tools_and_pardot_ci_vpc_peering.id}"
  route_table_id            = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route" "pardot_ci_to_pardotops_appdev" {
  destination_cidr_block    = "172.26.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.pardotops_appdev_and_pardot_ci_vpc_peering.id}"
  route_table_id            = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1a" {
  subnet_id      = "${aws_subnet.pardot_ci_us_east_1a.id}"
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1c" {
  subnet_id      = "${aws_subnet.pardot_ci_us_east_1c.id}"
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1b" {
  subnet_id      = "${aws_subnet.pardot_ci_us_east_1b.id}"
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1e" {
  subnet_id      = "${aws_subnet.pardot_ci_us_east_1e.id}"
  route_table_id = "${aws_vpc.pardot_ci.main_route_table_id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1a_dmz" {
  subnet_id      = "${aws_subnet.pardot_ci_us_east_1a_dmz.id}"
  route_table_id = "${aws_route_table.pardot_ci_route_dmz.id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1c_dmz" {
  subnet_id      = "${aws_subnet.pardot_ci_us_east_1c_dmz.id}"
  route_table_id = "${aws_route_table.pardot_ci_route_dmz.id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1b_dmz" {
  subnet_id      = "${aws_subnet.pardot_ci_us_east_1b_dmz.id}"
  route_table_id = "${aws_route_table.pardot_ci_route_dmz.id}"
}

resource "aws_route_table_association" "pardot_ci_us_east_1e_dmz" {
  subnet_id      = "${aws_subnet.pardot_ci_us_east_1e_dmz.id}"
  route_table_id = "${aws_route_table.pardot_ci_route_dmz.id}"
}

resource "aws_vpc_peering_connection" "pardot_atlassian_tools_and_pardot_ci_vpc_peering" {
  peer_owner_id = "${var.pardot_atlassian_acct_number}"
  peer_vpc_id   = "${var.pardot_atlassian_vpc_id}"
  vpc_id        = "${aws_vpc.pardot_ci.id}"
}

resource "aws_vpc_peering_connection" "pardotops_appdev_and_pardot_ci_vpc_peering" {
  peer_owner_id = "${var.pardotops_acct_number}"
  peer_vpc_id   = "${var.pardotops_appdev_vpc_id}"
  vpc_id        = "${aws_vpc.pardot_ci.id}"
}

resource aws_security_group "pardot2_bastion_1_1_ue1_ssh_ingress" {
  vpc_id = "${aws_vpc.pardot_ci.id}"

  ingress {
    from_port = "22"
    to_port   = "22"
    protocol  = "tcp"

    cidr_blocks = [
      "${var.pardot2-bastion1-1-ue1_aws_pardot_com_public_ip}/32",
      "${var.pardot2-bastion1-1-ue1_aws_pardot_com_private_ip}/32",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
