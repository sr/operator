resource "aws_vpc" "pardot0_ue1" {
  cidr_block           = "172.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "pardot0-ue1 production"
  }
}

resource "aws_route53_zone" "pardot0_ue1_aws_pardot_com_hosted_zone" {
  name    = "aws.pardot.com"
  comment = "Managed by Terraform. Private DNS for VPC: ${aws_vpc.pardot0_ue1.id} Only. Hosted solely in AWS."
  vpc_id  = "${aws_vpc.pardot0_ue1.id}"
}

resource "aws_subnet" "pardot0_ue1_1a" {
  vpc_id                  = "${aws_vpc.pardot0_ue1.id}"
  availability_zone       = "us-east-1a"
  cidr_block              = "172.30.0.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot0_ue1_1c" {
  vpc_id                  = "${aws_vpc.pardot0_ue1.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.30.32.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot0_ue1_1d" {
  vpc_id                  = "${aws_vpc.pardot0_ue1.id}"
  availability_zone       = "us-east-1d"
  cidr_block              = "172.30.64.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot0_ue1_1e" {
  vpc_id                  = "${aws_vpc.pardot0_ue1.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.30.96.0/19"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "pardot0_ue1_1a_dmz" {
  vpc_id                  = "${aws_vpc.pardot0_ue1.id}"
  availability_zone       = "us-east-1a"
  cidr_block              = "172.30.128.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pardot0_ue1_1c_dmz" {
  vpc_id                  = "${aws_vpc.pardot0_ue1.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.30.160.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pardot0_ue1_1d_dmz" {
  vpc_id                  = "${aws_vpc.pardot0_ue1.id}"
  availability_zone       = "us-east-1d"
  cidr_block              = "172.30.192.0/19"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "pardot0_ue1_1e_dmz" {
  vpc_id                  = "${aws_vpc.pardot0_ue1.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.30.224.0/19"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "pardot0_ue1_internet_gw" {
  vpc_id = "${aws_vpc.pardot0_ue1.id}"
}

resource "aws_eip" "pardot0_ue1_nat_gw" {
  vpc = true
}

resource "aws_nat_gateway" "pardot0_ue1_nat_gw" {
  allocation_id = "${aws_eip.pardot0_ue1_nat_gw.id}"
  subnet_id     = "${aws_subnet.pardot0_ue1_1a_dmz.id}"
}

resource "aws_route" "pardot0_ue1_route" {
  route_table_id         = "${aws_vpc.pardot0_ue1.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.pardot0_ue1_nat_gw.id}"
}

resource "aws_route_table" "pardot0_ue1_route_dmz" {
  vpc_id = "${aws_vpc.pardot0_ue1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.pardot0_ue1_internet_gw.id}"
  }

  route {
    cidr_block                = "172.28.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.pardot0_ue1_and_internal_tools_integration_vpc_peering.id}"
  }
}

resource "aws_route" "pardot0_ue1_to_internal_tools_integration" {
  destination_cidr_block    = "172.28.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.pardot0_ue1_and_internal_tools_integration_vpc_peering.id}"
  route_table_id            = "${aws_vpc.pardot0_ue1.main_route_table_id}"
}

resource "aws_route_table_association" "pardot0_ue1_1a" {
  subnet_id      = "${aws_subnet.pardot0_ue1_1a.id}"
  route_table_id = "${aws_vpc.pardot0_ue1.main_route_table_id}"
}

resource "aws_route_table_association" "pardot0_ue1_1c" {
  subnet_id      = "${aws_subnet.pardot0_ue1_1c.id}"
  route_table_id = "${aws_vpc.pardot0_ue1.main_route_table_id}"
}

resource "aws_route_table_association" "pardot0_ue1_1d" {
  subnet_id      = "${aws_subnet.pardot0_ue1_1d.id}"
  route_table_id = "${aws_vpc.pardot0_ue1.main_route_table_id}"
}

resource "aws_route_table_association" "pardot0_ue1_1e" {
  subnet_id      = "${aws_subnet.pardot0_ue1_1e.id}"
  route_table_id = "${aws_vpc.pardot0_ue1.main_route_table_id}"
}

resource "aws_route_table_association" "pardot0_ue1_1a_dmz" {
  subnet_id      = "${aws_subnet.pardot0_ue1_1a_dmz.id}"
  route_table_id = "${aws_route_table.pardot0_ue1_route_dmz.id}"
}

resource "aws_route_table_association" "pardot0_ue1_1c_dmz" {
  subnet_id      = "${aws_subnet.pardot0_ue1_1c_dmz.id}"
  route_table_id = "${aws_route_table.pardot0_ue1_route_dmz.id}"
}

resource "aws_route_table_association" "pardot0_ue1_1d_dmz" {
  subnet_id      = "${aws_subnet.pardot0_ue1_1d_dmz.id}"
  route_table_id = "${aws_route_table.pardot0_ue1_route_dmz.id}"
}

resource "aws_route_table_association" "pardot0_ue1_1e_dmz" {
  subnet_id      = "${aws_subnet.pardot0_ue1_1e_dmz.id}"
  route_table_id = "${aws_route_table.pardot0_ue1_route_dmz.id}"
}

resource "aws_security_group" "pardot0_ue1_http_lb" {
  name        = "internal_apps_http_lb"
  description = "Allow HTTP/HTTPS from SFDC VPN only"
  vpc_id      = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${concat(var.aloha_vpn_cidr_blocks, var.sfdc_proxyout_cidr_blocks)}"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${concat(var.aloha_vpn_cidr_blocks, var.sfdc_proxyout_cidr_blocks)}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "pardot0_ue1_dc_only_http_lb" {
  name        = "internal_apps_dc_only_http_lb"
  description = "Allow HTTP/HTTPS from SFDC datacenters only"
  vpc_id      = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.sfdc_proxyout_cidr_blocks}"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.sfdc_proxyout_cidr_blocks}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "pardot0_ue1" {
  name        = "internal_apps"
  description = "Internal Apps DB Subnet"

  subnet_ids = [
    "${aws_subnet.pardot0_ue1_1a.id}",
    "${aws_subnet.pardot0_ue1_1c.id}",
    "${aws_subnet.pardot0_ue1_1d.id}",
    "${aws_subnet.pardot0_ue1_1e.id}",
  ]
}

# VPC Peering with tools_egress

resource "aws_vpc_peering_connection" "pardot0_ue1_peer_tools_egress" {
  peer_owner_id = "010094454891"              # pardot-atlassian
  peer_vpc_id   = "vpc-b64769d2"              # tools_egress
  vpc_id        = "${aws_vpc.pardot0_ue1.id}"
}

resource "aws_route" "pardot0_ue1_route_tools_egress" {
  route_table_id            = "${aws_vpc.pardot0_ue1.main_route_table_id}"
  destination_cidr_block    = "172.29.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.pardot0_ue1_peer_tools_egress.id}"
}

# Bastion host

resource "aws_security_group" "pardot0_ue1_bastion" {
  name        = "internal_apps_bastion"
  description = "Bastion host, allows SSH from SFDC VPNs"
  vpc_id      = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.aloha_vpn_cidr_blocks}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pardot0_ue1_bastion" {
  ami                    = "${var.centos_6_hvm_ebs_ami}"
  instance_type          = "t2.small"
  key_name               = "internal_apps"
  subnet_id              = "${aws_subnet.pardot0_ue1_1a_dmz.id}"
  vpc_security_group_ids = ["${aws_security_group.pardot0_ue1_bastion.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = false
  }

  tags {
    terraform = "true"
    Name      = "pardot0-bastion1-1-ue1"
  }
}

resource "aws_eip" "pardot0_ue1_bastion" {
  vpc      = true
  instance = "${aws_instance.pardot0_ue1_bastion.id}"
}

resource "aws_instance" "pardot0_ue1_bastion_2" {
  ami                    = "${var.centos_6_hvm_ebs_ami}"
  instance_type          = "t2.small"
  key_name               = "internal_apps"
  subnet_id              = "${aws_subnet.pardot0_ue1_1d_dmz.id}"
  vpc_security_group_ids = ["${aws_security_group.pardot0_ue1_bastion.id}"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = false
  }

  tags {
    terraform = "true"
    Name      = "pardot0-bastion1-2-ue1"
  }
}

resource "aws_eip" "pardot0_ue1_bastion_2" {
  vpc      = true
  instance = "${aws_instance.pardot0_ue1_bastion_2.id}"
}

resource "aws_route53_record" "pardot0_ue1_bastion1-1_Arecord" {
  zone_id = "${aws_route53_zone.pardot0_ue1_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-bastion1-1-ue1.aws.pardot.com"
  records = ["${aws_instance.pardot0_ue1_bastion.private_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "pardot0_ue1_bastion1-2_Arecord" {
  zone_id = "${aws_route53_zone.pardot0_ue1_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-bastion1-2-ue1.aws.pardot.com"
  records = ["${aws_instance.pardot0_ue1_bastion_2.private_ip}"]
  type    = "A"
  ttl     = "900"
}
