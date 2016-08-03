# A VPC with the sole purpose of being peered with so egress traffic appears
# from a whitelisted IP.
resource "aws_vpc" "tools_egress" {
  cidr_block = "172.29.0.0/16"
  tags {
    Name = "tools_egress"
  }
}

resource "aws_security_group" "tools_egress_proxy" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  name_prefix = "tools_egress_proxy"
  description = "Security group for NAT gateway"

  ingress {
    from_port = 8888
    to_port = 8888
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.tools_egress.cidr_block}",
      "172.30.0.0/16" # internal_apps from pardotops
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "tools_egress_us_east_1b" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  availability_zone = "us-east-1b"
  cidr_block = "172.29.0.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "tools_egress_us_east_1c" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.29.32.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "tools_egress_us_east_1d" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.29.64.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "tools_egress_us_east_1e" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.29.96.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "tools_egress_us_east_1b_dmz" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  availability_zone = "us-east-1b"
  cidr_block = "172.29.128.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "tools_egress_us_east_1c_dmz" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.29.160.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "tools_egress_us_east_1d_dmz" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.29.192.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "tools_egress_us_east_1e_dmz" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.29.224.0/19"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "tools_egress_internet_gw" {
  vpc_id = "${aws_vpc.tools_egress.id}"
}

resource "aws_route" "tools_egress_to_internal_tools" {
  route_table_id = "${aws_vpc.tools_egress.main_route_table_id}"
  destination_cidr_block = "172.30.0.0/16"
  vpc_peering_connection_id = "pcx-fbf25a92" # pardotops/internal_apps
}

resource "aws_route_table" "tools_egress_route_dmz" {
  vpc_id = "${aws_vpc.tools_egress.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tools_egress_internet_gw.id}"
  }
  route {
    cidr_block = "172.30.0.0/16"
    vpc_peering_connection_id = "pcx-fbf25a92" # pardotops/internal_apps
  }
}

resource "aws_route_table_association" "tools_egress_us_east_1b" {
  subnet_id = "${aws_subnet.tools_egress_us_east_1b.id}"
  route_table_id = "${aws_vpc.tools_egress.main_route_table_id}"
}

resource "aws_route_table_association" "tools_egress_us_east_1c" {
  subnet_id = "${aws_subnet.tools_egress_us_east_1c.id}"
  route_table_id = "${aws_vpc.tools_egress.main_route_table_id}"
}

resource "aws_route_table_association" "tools_egress_us_east_1d" {
  subnet_id = "${aws_subnet.tools_egress_us_east_1d.id}"
  route_table_id = "${aws_vpc.tools_egress.main_route_table_id}"
}

resource "aws_route_table_association" "tools_egress_us_east_1e" {
  subnet_id = "${aws_subnet.tools_egress_us_east_1e.id}"
  route_table_id = "${aws_vpc.tools_egress.main_route_table_id}"
}

resource "aws_route_table_association" "tools_egress_us_east_1b_dmz" {
  subnet_id = "${aws_subnet.tools_egress_us_east_1b_dmz.id}"
  route_table_id = "${aws_route_table.tools_egress_route_dmz.id}"
}

resource "aws_route_table_association" "tools_egress_us_east_1c_dmz" {
  subnet_id = "${aws_subnet.tools_egress_us_east_1c_dmz.id}"
  route_table_id = "${aws_route_table.tools_egress_route_dmz.id}"
}

resource "aws_route_table_association" "tools_egress_us_east_1d_dmz" {
  subnet_id = "${aws_subnet.tools_egress_us_east_1d_dmz.id}"
  route_table_id = "${aws_route_table.tools_egress_route_dmz.id}"
}

resource "aws_route_table_association" "tools_egress_us_east_1e_dmz" {
  subnet_id = "${aws_subnet.tools_egress_us_east_1e_dmz.id}"
  route_table_id = "${aws_route_table.tools_egress_route_dmz.id}"
}

resource "aws_eip" "tools_egress_proxy" {
  vpc = true
  instance = "${aws_instance.tools_egress_proxy.id}"
}

resource "aws_instance" "tools_egress_proxy" {
  ami = "ami-6d1c2007" # CentOS 7 with Updates
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.tools_egress_proxy.id}"]
  subnet_id = "${aws_subnet.tools_egress_us_east_1b_dmz.id}"
  private_ip = "172.29.129.1"
  user_data = "${file("tinyproxy_user_data.sh")}"
  key_name = "pardot-atlassian-instances"
  tags {
    Name = "tools_egress_proxy"
  }
}
