variable "num_afy_hosts" {
  type = "string"
  default = "3"
}

resource "aws_security_group" "artifactory_instance_secgroup" {
  name = "artifactory_instance_secgroup"
  vpc_id = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${aws_instance.internal_apps_bastion.public_ip}/32",
      "${aws_instance.internal_apps_bastion_2.public_ip}/32"
    ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${aws_vpc.artifactory_integration.cidr_block}",
      "${aws_vpc.internal_apps.cidr_block}",
      "172.31.0.0/16", # pardot-atlassian: default vpc
      "192.168.128.0/22" # pardot-ci: default vpc
    ]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${aws_vpc.artifactory_integration.cidr_block}",
      "${aws_vpc.internal_apps.cidr_block}",
      "172.31.0.0/16", # pardot-atlassian: default vpc
      "192.168.128.0/22" # pardot-ci: default vpc
    ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.artifactory_dc_only_http_lb.id}",
      "${aws_security_group.artifactory_http_lb.id}",
      "${aws_security_group.artifactory_internal_elb_secgroup.id}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "artifactory_http_lb" {
  name = "artifactory_http_lb"
  description = "Allow HTTP/HTTPS from SFDC VPN only"
  vpc_id = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = "${var.aloha_vpn_cidr_blocks}"
    self = "true"
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

resource "aws_security_group" "artifactory_dc_only_http_lb" {
  name = "artifactory_dc_only_http_lb"
  description = "Allow HTTP/HTTPS from SFDC datacenters only"
  vpc_id = "${aws_vpc.artifactory_integration.id}"

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
resource "aws_security_group" "artifactory_internal_elb_secgroup" {
  name = "artifactory_internal_elb_secgroup"
  description = "Allow HTTP/HTTPS from SFDC datacenters only"
  vpc_id = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${aws_vpc.artifactory_integration.cidr_block}",
      "${aws_vpc.internal_apps.cidr_block}",
      "172.31.0.0/16", # pardot-atlassian: default vpc
      "192.168.128.0/22" # pardot-ci: default vpc
    ]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${aws_vpc.artifactory_integration.cidr_block}",
      "${aws_vpc.internal_apps.cidr_block}",
      "172.31.0.0/16", # pardot-atlassian: default vpc
      "192.168.128.0/22" # pardot-ci: default vpc
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pardot0-artifactory1-1-ue1" {
  ami = "${var.centos_7_hvm_ebs_ami_2TB_ENH_NTWK_CHEF_UE1_PROD_AFY_ONLY}"
  instance_type = "c4.4xlarge"
  private_ip="172.28.0.138"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}"
  associate_public_ip_address = false
  vpc_security_group_ids = [
    "${aws_security_group.artifactory_instance_secgroup.id}",
    "${aws_security_group.artifactory_http_lb.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "2047"
    delete_on_termination = true
  }
  tags {
    Name = "pardot0-artifactory1-1-ue1"
    terraform = "true"
  }
}

resource "aws_eip" "elasticip_pardot0-artifactory1-1-ue1" {
  vpc = true
  instance = "${aws_instance.pardot0-artifactory1-1-ue1.id}"
}

resource "aws_route53_record" "pardot0-artifactory1-1-ue1_arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name = "pardot0-artifactory1-1-ue1.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_eip.elasticip_pardot0-artifactory1-1-ue1.public_ip}"]
  type = "A"
  ttl = 900
}

resource "aws_route53_record" "pardot0-artifactory-internal1-1-ue1_arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name = "pardot0-artifactory-internal1-1-ue1.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_instance.pardot0-artifactory1-1-ue1.private_ip}"]
  type = "A"
  ttl = 900
}

resource "aws_instance" "pardot0-artifactory1-2-ue1" {
  ami = "${var.centos_7_hvm_ebs_ami_2TB_ENH_NTWK_CHEF_UE1_PROD_AFY_ONLY}"
  instance_type = "c4.4xlarge"
  private_ip="172.28.0.209"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1d_dmz.id}"
  associate_public_ip_address = false
  vpc_security_group_ids = [
    "${aws_security_group.artifactory_instance_secgroup.id}",
    "${aws_security_group.artifactory_http_lb.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "2047"
    delete_on_termination = true
  }
  tags {
    Name = "pardot0-artifactory1-2-ue1"
    terraform = "true"
  }
}

resource "aws_eip" "elasticip_pardot0-artifactory1-2-ue1" {
  vpc = true
  instance = "${aws_instance.pardot0-artifactory1-2-ue1.id}"
}

resource "aws_route53_record" "pardot0-artifactory1-2-ue1_arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name = "pardot0-artifactory1-2-ue1.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_eip.elasticip_pardot0-artifactory1-2-ue1.public_ip}"]
  type = "A"
  ttl = 900
}

resource "aws_route53_record" "pardot0-artifactory-internal1-2-ue1_arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name = "pardot0-artifactory-internal1-2-ue1.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_instance.pardot0-artifactory1-2-ue1.private_ip}"]
  type = "A"
  ttl = 900
}

resource "aws_instance" "pardot0-artifactory1-3-ue1" {
  ami = "${var.centos_7_hvm_ebs_ami_2TB_ENH_NTWK_CHEF_UE1_PROD_AFY_ONLY}"
  instance_type = "c4.4xlarge"
  private_ip="172.28.0.182"
  key_name = "internal_apps"
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1c_dmz.id}"
  associate_public_ip_address = false
  vpc_security_group_ids = [
    "${aws_security_group.artifactory_instance_secgroup.id}",
    "${aws_security_group.artifactory_http_lb.id}"
  ]
  root_block_device {
    volume_type = "gp2"
    volume_size = "2047"
    delete_on_termination = true
  }
  tags {
    Name = "pardot0-artifactory1-3-ue1"
    terraform = "true"
  }
}

resource "aws_eip" "elasticip_pardot0-artifactory1-3-ue1" {
  vpc = true
  instance = "${aws_instance.pardot0-artifactory1-3-ue1.id}"
}

resource "aws_route53_record" "pardot0-artifactory1-3-ue1_arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name = "pardot0-artifactory1-3-ue1.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_eip.elasticip_pardot0-artifactory1-3-ue1.public_ip}"]
  type = "A"
  ttl = 900
}

resource "aws_route53_record" "pardot0-artifactory-internal1-3-ue1_arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name = "pardot0-artifactory-internal1-3-ue1.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_instance.pardot0-artifactory1-3-ue1.private_ip}"]
  type = "A"
  ttl = 900
}

resource "aws_elb" "artifactory_public_elb" {
  name = "afy-pblc-elb-dev-pardot-com"
  security_groups = [
    "${aws_security_group.artifactory_dc_only_http_lb.id}",
    "${aws_security_group.artifactory_http_lb.id}"
  ]
  subnets = [
    "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1c_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1d_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1e_dmz.id}",
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 30
  instances = [
    "${aws_instance.pardot0-artifactory1-1-ue1.id}",
    "${aws_instance.pardot0-artifactory1-2-ue1.id}",
    "${aws_instance.pardot0-artifactory1-3-ue1.id}"
  ]

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 80
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 4
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/artifactory/api/system/ping"
    interval = 5
  }

  tags {
    Name = "artifactory-public-elb"
  }
}

resource "aws_elb" "artifactory_private_elb" {
  internal = true
  name = "afy-prvt-elb-dev-pardot-com"
  security_groups = [
    "${aws_security_group.artifactory_internal_elb_secgroup.id}"
  ]

  subnets = [
    "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1c_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1d_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1e_dmz.id}"
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 30
  instances = [
    "${aws_instance.pardot0-artifactory1-1-ue1.id}",
    "${aws_instance.pardot0-artifactory1-2-ue1.id}",
    "${aws_instance.pardot0-artifactory1-3-ue1.id}"
  ]

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 80
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"
  }

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 4
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/artifactory/api/system/ping"
    interval = 5
  }

  tags {
    Name = "artifactory-private-elb"
  }
}

resource "aws_iam_user" "artifactory_sysacct" {
  name = "artifactorysysacct"
}

resource "aws_s3_bucket" "artifactory_s3_filestore" {
  bucket = "artifactory_s3_filestore"
  acl = "private"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "allow artifactory sysacct",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.artifactory_sysacct.arn}"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::artifactory_s3_filestore",
        "arn:aws:s3:::artifactory_s3_filestore/*"
      ]
    },
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::artifactory_s3_filestore/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    },
    {
      "Sid": "DenyUnEncryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::artifactory_s3_filestore/*",
      "Condition": {
        "Null": {
          "s3:x-amz-server-side-encryption": "true"
        }
      }
    }
  ]
}
EOF
  tags {
    Name = "artifactory_s3_filestore"
    terraform = "true"
  }
}

resource "aws_vpc" "artifactory_integration" {
cidr_block = "172.28.0.0/24"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "artifactory_integration"
  }
  enable_dns_hostnames = true
}

resource "aws_subnet" "artifactory_integration_us_east_1a" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
  availability_zone = "us-east-1a"
  cidr_block = "172.28.0.0/27"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "artifactory_integration_us_east_1c" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.28.0.32/27"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "artifactory_integration_us_east_1d" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.28.0.64/27"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "artifactory_integration_us_east_1e" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.28.0.96/27"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "artifactory_integration_us_east_1a_dmz" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
  availability_zone = "us-east-1a"
  cidr_block = "172.28.0.128/27"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "artifactory_integration_us_east_1c_dmz" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
  availability_zone = "us-east-1c"
  cidr_block = "172.28.0.160/27"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "artifactory_integration_us_east_1d_dmz" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
  availability_zone = "us-east-1d"
  cidr_block = "172.28.0.192/27"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "artifactory_integration_us_east_1e_dmz" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
  availability_zone = "us-east-1e"
  cidr_block = "172.28.0.224/27"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "artifactory_integration_internet_gw" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
}

resource "aws_eip" "artifactory_integration_nat_gw" {
  vpc = true
}

resource "aws_nat_gateway" "artifactory_integration_nat_gw" {
  allocation_id = "${aws_eip.artifactory_integration_nat_gw.id}"
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}"
}

resource "aws_route" "artifactory_integration_route" {
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.artifactory_integration_nat_gw.id}"
}

resource "aws_route_table" "artifactory_integration_route_dmz" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.artifactory_integration_internet_gw.id}"
  }
  route {
    cidr_block = "172.30.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.internal_apps_and_artifactory_integration_vpc_peering.id}"
  }
  route {
    #TODO: delete
    cidr_block = "192.168.128.0/22" 
    vpc_peering_connection_id = "${aws_vpc_peering_connection.legacy_pardot_ci_and_artifactory_integration_vpc_peering.id}"
  }

}

resource "aws_route" "artifactory_integration_to_legacy_pardot_ci" {
  #TODO: delete
  destination_cidr_block = "192.168.128.0/22"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.legacy_pardot_ci_and_artifactory_integration_vpc_peering.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route" "artifactory_integration_to_internal_apps" {
  destination_cidr_block = "172.30.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal_apps_and_artifactory_integration_vpc_peering.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1a" {
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1a.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1c" {
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1c.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1d" {
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1d.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1e" {
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1e.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1a_dmz" {
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}"
  route_table_id = "${aws_route_table.artifactory_integration_route_dmz.id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1c_dmz" {
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1c_dmz.id}"
  route_table_id = "${aws_route_table.artifactory_integration_route_dmz.id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1d_dmz" {
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1d_dmz.id}"
  route_table_id = "${aws_route_table.artifactory_integration_route_dmz.id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1e_dmz" {
  subnet_id = "${aws_subnet.artifactory_integration_us_east_1e_dmz.id}"
  route_table_id = "${aws_route_table.artifactory_integration_route_dmz.id}"
}

resource "aws_security_group" "artifactory_integration_mysql_ingress" {
  name = "artifactory_integration_mysql_ingress"
  description = "Allow mysql from artifactory instances only"
  vpc_id = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      "${aws_subnet.artifactory_integration_us_east_1a.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1a_dmz.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1c.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1c_dmz.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1d.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1d_dmz.cidr_block}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "artifactory_integration" {
  name = "artifactory_integration"
  description = "Pardot CI DB Subnet"
  subnet_ids = [
    "${aws_subnet.artifactory_integration_us_east_1a.id}",
    "${aws_subnet.artifactory_integration_us_east_1c.id}",
    "${aws_subnet.artifactory_integration_us_east_1d.id}",
    "${aws_subnet.artifactory_integration_us_east_1e.id}"
  ]
}
resource "aws_vpc_peering_connection" "internal_apps_and_artifactory_integration_vpc_peering" {
  peer_owner_id = "${var.pardotops_account_number}"
  peer_vpc_id = "${aws_vpc.internal_apps.id}"
  vpc_id = "${aws_vpc.artifactory_integration.id}"
}

# Temporary peering with legacy pardot-ci account
resource "aws_vpc_peering_connection" "legacy_pardot_ci_and_artifactory_integration_vpc_peering" {
  #TODO: delete
  peer_owner_id = "096113534078"
  peer_vpc_id = "vpc-4d96a928"
  vpc_id = "${aws_vpc.artifactory_integration.id}"
}
