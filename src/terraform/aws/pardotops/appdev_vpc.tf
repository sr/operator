resource "aws_route53_zone" "appdev_aws_pardot_com_hosted_zone" {
  name = "aws.pardot.com"
  comment = "Managed by Terraform. Private DNS for VPC: ${aws_vpc.appdev.id} Only. Hosted solely in AWS."
  vpc_id = "${aws_vpc.appdev.id}"
}

resource "aws_vpc" "appdev" {
  cidr_block = "172.26.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "appdev"
  }
}

resource "aws_subnet" "appdev_us_east_1a" {
  vpc_id = "${aws_vpc.appdev.id}"
  availability_zone = "us-east-1a"
  cidr_block = "172.26.0.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name = "appdev_us_east_1a"
  }
}

resource "aws_subnet" "appdev_us_east_1c" {
  vpc_id = "${aws_vpc.appdev.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.26.32.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name = "appdev_us_east_1c"
  }
}

resource "aws_subnet" "appdev_us_east_1d" {
  vpc_id = "${aws_vpc.appdev.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.26.64.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name = "appdev_us_east_1d"
  }
}

resource "aws_subnet" "appdev_us_east_1e" {
  vpc_id = "${aws_vpc.appdev.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.26.96.0/19"
  map_public_ip_on_launch = false
  tags = {
    Name = "appdev_us_east_1e"
  }
}

resource "aws_subnet" "appdev_us_east_1a_dmz" {
  vpc_id = "${aws_vpc.appdev.id}"
  availability_zone = "us-east-1a"
  cidr_block = "172.26.128.0/19"
  map_public_ip_on_launch = true
  tags = {
    Name = "appdev_us_east_1a_dmz"
  }
}

resource "aws_subnet" "appdev_us_east_1c_dmz" {
  vpc_id = "${aws_vpc.appdev.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.26.160.0/19"
  map_public_ip_on_launch = true
  tags = {
    Name = "appdev_us_east_1c_dmz"
  }
}

resource "aws_subnet" "appdev_us_east_1d_dmz" {
  vpc_id = "${aws_vpc.appdev.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.26.192.0/19"
  map_public_ip_on_launch = true
  tags = {
    Name = "appdev_us_east_1d_dmz"
  }
}

resource "aws_subnet" "appdev_us_east_1e_dmz" {
  vpc_id = "${aws_vpc.appdev.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.26.224.0/19"
  map_public_ip_on_launch = true
  tags = {
    Name = "appdev_us_east_1e_dmz"
  }
}

resource "aws_internet_gateway" "appdev_internet_gw" {
  vpc_id = "${aws_vpc.appdev.id}"
}

resource "aws_eip" "appdev_nat_gw" {
  vpc = true
}

resource "aws_nat_gateway" "appdev_nat_gw" {
  allocation_id = "${aws_eip.appdev_nat_gw.id}"
  subnet_id = "${aws_subnet.appdev_us_east_1a_dmz.id}"
}

resource "aws_route" "appdev_route" {
  route_table_id = "${aws_vpc.appdev.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.appdev_nat_gw.id}"
}

resource "aws_route_table" "appdev_route_dmz" {
  vpc_id = "${aws_vpc.appdev.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.appdev_internet_gw.id}"
  }
  route {
    cidr_block = "172.31.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.appdev_and_pardot_atlassian_vpc_peering.id}"
  }
//  route {
//    cidr_block = "172.27.0.0/16"
//    vpc_peering_connection_id = "${aws_vpc_peering_connection.appdev_and_pardot_ci_vpc_peering.id}"
//  }
}

resource "aws_route" "appdev_and_pardot_atlassian_route" {
  destination_cidr_block = "172.31.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.appdev_and_pardot_atlassian_vpc_peering.id}"
  route_table_id = "${aws_vpc.appdev.main_route_table_id}"
}

//resource "aws_route" "appdev_and_pardot_ci_route" {
//  destination_cidr_block = "172.27.0.0/16"
//  vpc_peering_connection_id = "${aws_vpc_peering_connection.appdev_and_pardot_ci_vpc_peering.id}"
//  route_table_id = "${aws_vpc.appdev.main_route_table_id}"
//}

resource "aws_route_table_association" "appdev_us_east_1a" {
  subnet_id = "${aws_subnet.appdev_us_east_1a.id}"
  route_table_id = "${aws_vpc.appdev.main_route_table_id}"
}

resource "aws_route_table_association" "appdev_us_east_1c" {
  subnet_id = "${aws_subnet.appdev_us_east_1c.id}"
  route_table_id = "${aws_vpc.appdev.main_route_table_id}"
}

resource "aws_route_table_association" "appdev_us_east_1d" {
  subnet_id = "${aws_subnet.appdev_us_east_1d.id}"
  route_table_id = "${aws_vpc.appdev.main_route_table_id}"
}

resource "aws_route_table_association" "appdev_us_east_1e" {
  subnet_id = "${aws_subnet.appdev_us_east_1e.id}"
  route_table_id = "${aws_vpc.appdev.main_route_table_id}"
}

resource "aws_route_table_association" "appdev_us_east_1a_dmz" {
  subnet_id = "${aws_subnet.appdev_us_east_1a_dmz.id}"
  route_table_id = "${aws_route_table.appdev_route_dmz.id}"
}

resource "aws_route_table_association" "appdev_us_east_1c_dmz" {
  subnet_id = "${aws_subnet.appdev_us_east_1c_dmz.id}"
  route_table_id = "${aws_route_table.appdev_route_dmz.id}"
}

resource "aws_route_table_association" "appdev_us_east_1d_dmz" {
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  route_table_id = "${aws_route_table.appdev_route_dmz.id}"
}

resource "aws_route_table_association" "appdev_us_east_1e_dmz" {
  subnet_id = "${aws_subnet.appdev_us_east_1e_dmz.id}"
  route_table_id = "${aws_route_table.appdev_route_dmz.id}"
}

resource "aws_security_group" "appdev_vpc_default" {
  name = "appdev_vpc_default"
  description = "Allow SSH from bastion on public and private interfaces"
  vpc_id = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${aws_eip.appdev_bastion_eip.public_ip}/32",
      "${aws_instance.appdev_bastion.private_ip}/32"
    ]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.appdev_sfdc_vpn_ssh.id}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "appdev_sfdc_vpn_http_https" {
  name = "appdev_sfdc_vpn_http_https"
  description = "Allow HTTP/HTTPS traffic from SFDC VPN"
  vpc_id = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = "${var.aloha_vpn_cidr_blocks}"
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = "${var.aloha_vpn_cidr_blocks}"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "appdev_sfdc_vpn_ssh" {
  name = "appdev_sfdc_vpn_ssh"
  description = "Allow SSH traffic from SFDC VPN"
  vpc_id = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "${var.aloha_vpn_cidr_blocks}"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "appdev_bastion" {
  ami = "${var.centos_6_hvm_50gb_chefdev_ami}"
  instance_type = "t2.small"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = ["${aws_security_group.appdev_sfdc_vpn_ssh.id}"]
  private_ip = "172.26.220.43"
  associate_public_ip_address = false
  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
    delete_on_termination = true
  }
  tags {
    terraform = "true"
    Name = "pardot2-bastion1-1-ue1"
  }
}

resource "aws_eip" "appdev_bastion_eip" {
  vpc = true
  instance = "${aws_instance.appdev_bastion.id}"
}

resource "aws_route53_record" "appdev_bastion_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name = "pardot2-bastion1-1-ue1.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_eip.appdev_bastion_eip.public_ip}"]
  type = "A"
  ttl = "900"
}

resource "aws_vpc_peering_connection" "appdev_and_pardot_atlassian_vpc_peering" {
  peer_owner_id = "${var.pardot_atlassian_acct_number}"
  peer_vpc_id = "${var.pardot_atlassian_vpc_id}"
  vpc_id = "${aws_vpc.appdev.id}"
}

