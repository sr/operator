resource "aws_route53_zone_association" "artifactory_integration_to_internal_apps_dns_association" {
  vpc_id  = "${aws_vpc.artifactory_integration.id}"
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.id}"
}

resource "aws_security_group" "artifactory_instance_secgroup" {
  name   = "artifactory_instance_secgroup"
  vpc_id = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_instance.internal_apps_bastion.public_ip}/32",
      "${aws_instance.internal_apps_bastion_2.public_ip}/32",
      "${aws_instance.internal_apps_bastion.private_ip}/32",
      "${aws_instance.internal_apps_bastion_2.private_ip}/32",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.artifactory_dc_only_http_lb.id}",
      "${aws_security_group.artifactory_http_lb.id}",
      "${aws_security_group.artifactory_internal_elb_secgroup.id}",
    ]
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.artifactory_integration.cidr_block}",
    ]
  }

  ingress {
    from_port = 8081
    to_port   = 8081
    protocol  = "tcp"
    self      = true
  }

  # Notes on why "aws_vpc.artifactory_integration.cidr_block" above and below
  # see: https://www.jfrog.com/confluence/display/RTF/HA+Installation+and+Setup#InstallationandSetup-ConfiguringArtifactoryHA
  # "both the Hazelcast port (10001) and the Tomcat port (default 8081) should be open between all nodes."
  ingress {
    from_port = 10001
    to_port   = 10001
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.artifactory_integration.cidr_block}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "artifactory_http_lb" {
  name        = "artifactory_http_lb"
  description = "Allow HTTP/HTTPS from SFDC VPN only"
  vpc_id      = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.aloha_vpn_cidr_blocks}"
    self        = "true"
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
      "${var.legacy_artifactory_instance_ip}/32", # TODO: deleteme post switchover
      "${var.pardot_ci_nat_gw_public_ip}/32",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.artifact_cache_server.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "artifactory_http_lb_internal" {
  name        = "artifactory_http_lb_internal"
  description = "Allow HTTP/HTTPS from SFDC VPN only"
  vpc_id      = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.artifact_cache_server.id}",
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.artifact_cache_server.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "artifactory_dc_only_http_lb" {
  name        = "artifactory_dc_only_http_lb"
  description = "Allow HTTP/HTTPS from SFDC datacenters only"
  vpc_id      = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "136.147.104.20/30", # pardot-proxyout1-{1,2,3,4}-dfw
      "136.147.96.20/30",  # pardot-proxyout1-{1,2,3,4}-phx
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "136.147.104.20/30", # pardot-proxyout1-{1,2,3,4}-dfw
      "136.147.96.20/30",  # pardot-proxyout1-{1,2,3,4}-phx
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "artifactory_internal_elb_secgroup" {
  name        = "artifactory_internal_elb_secgroup"
  description = "Allow HTTP/HTTPS from SFDC datacenters only"
  vpc_id      = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${aws_vpc.artifactory_integration.cidr_block}",
      "${aws_vpc.internal_apps.cidr_block}",
      "172.31.0.0/16",                                 # pardot-atlassian: default vpc
      "192.168.128.0/22",                              # pardot-ci: default vpc
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}",
      "${aws_vpc.artifactory_integration.cidr_block}",
      "${aws_vpc.internal_apps.cidr_block}",
      "172.31.0.0/16",                                 # pardot-atlassian: default vpc
      "192.168.128.0/22",                              # pardot-ci: default vpc
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pardot0-artifactory1-1-ue1" {
  ami                         = "${var.centos_7_hvm_ebs_ami_2TB_ENH_NTWK_CHEF_UE1_PROD_AFY_ONLY}"
  instance_type               = "c4.4xlarge"
  key_name                    = "internal_apps"
  subnet_id                   = "${aws_subnet.artifactory_integration_us_east_1a.id}"
  associate_public_ip_address = false

  vpc_security_group_ids = [
    "${aws_security_group.artifactory_instance_secgroup.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "2047"
    delete_on_termination = true
  }

  tags {
    Name      = "pardot0-artifactory1-1-ue1"
    terraform = "true"
  }

  private_ip           = "172.28.0.21"                                                 #Required by HA-Artifactory
  iam_instance_profile = "${aws_iam_instance_profile.artifactory_instance_profile.id}"
}

resource "aws_route53_record" "pardot0-artifactory1-1-ue1_arecord" {
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-artifactory1-1-ue1.${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.pardot0-artifactory1-1-ue1.private_ip}"]
  type    = "A"
  ttl     = 900
}

resource "aws_instance" "pardot0-artifactory1-2-ue1" {
  ami                         = "${var.centos_7_hvm_ebs_ami_2TB_ENH_NTWK_CHEF_UE1_PROD_AFY_ONLY}"
  instance_type               = "c4.4xlarge"
  key_name                    = "internal_apps"
  subnet_id                   = "${aws_subnet.artifactory_integration_us_east_1d.id}"
  associate_public_ip_address = false

  vpc_security_group_ids = [
    "${aws_security_group.artifactory_instance_secgroup.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "2047"
    delete_on_termination = true
  }

  tags {
    Name      = "pardot0-artifactory1-2-ue1"
    terraform = "true"
  }

  private_ip           = "172.28.0.83"                                                 #Required by HA-Artifactory
  iam_instance_profile = "${aws_iam_instance_profile.artifactory_instance_profile.id}"
}

resource "aws_route53_record" "pardot0-artifactory1-2-ue1_arecord" {
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-artifactory1-2-ue1.${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.pardot0-artifactory1-2-ue1.private_ip}"]
  type    = "A"
  ttl     = 900
}

resource "aws_instance" "pardot0-artifactory1-3-ue1" {
  ami                         = "${var.centos_7_hvm_ebs_ami_2TB_ENH_NTWK_CHEF_UE1_PROD_AFY_ONLY}"
  instance_type               = "c4.4xlarge"
  key_name                    = "internal_apps"
  subnet_id                   = "${aws_subnet.artifactory_integration_us_east_1c.id}"
  associate_public_ip_address = false

  vpc_security_group_ids = [
    "${aws_security_group.artifactory_instance_secgroup.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "2047"
    delete_on_termination = true
  }

  tags {
    Name      = "pardot0-artifactory1-3-ue1"
    terraform = "true"
  }

  private_ip           = "172.28.0.54"                                                 #Required by HA-Artifactory
  iam_instance_profile = "${aws_iam_instance_profile.artifactory_instance_profile.id}"
}

resource "aws_route53_record" "pardot0-artifactory1-3-ue1_arecord" {
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-artifactory1-3-ue1.${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.pardot0-artifactory1-3-ue1.private_ip}"]
  type    = "A"
  ttl     = 900
}

resource "aws_iam_role" "artifactory_s3_access_iam_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "artifactory_instance_profile" {
  name  = "web_instance_profile"
  roles = ["${aws_iam_role.artifactory_s3_access_iam_role.name}"]
}

resource "aws_s3_bucket" "artifactory-s3-filestore" {
  bucket              = "artifactory-s3-filestore"
  acl                 = "private"
  acceleration_status = "Enabled"

  # for more info on the Elastic Load Balancing Account Number:
  # http://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html#attach-bucket-policy
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "allow artifactory iam role",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.artifactory_s3_access_iam_role.arn}"
      },
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::artifactory-s3-filestore",
        "arn:aws:s3:::artifactory-s3-filestore/*"
      ]
    },
    {
      "Sid": "DenyIncorrectEncryptionHeader",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::artifactory-s3-filestore/*",
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
      "Resource": "arn:aws:s3:::artifactory-s3-filestore/*",
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
    Name      = "artifactory-s3-filestore"
    terraform = "true"
  }
}

resource "aws_vpc" "artifactory_integration" {
  cidr_block           = "172.28.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "artifactory_integration"
  }
}

resource "aws_subnet" "artifactory_integration_us_east_1a" {
  vpc_id                  = "${aws_vpc.artifactory_integration.id}"
  availability_zone       = "us-east-1a"
  cidr_block              = "172.28.0.0/27"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "artifactory_integration_us_east_1c" {
  vpc_id                  = "${aws_vpc.artifactory_integration.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.28.0.32/27"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "artifactory_integration_us_east_1d" {
  vpc_id                  = "${aws_vpc.artifactory_integration.id}"
  availability_zone       = "us-east-1d"
  cidr_block              = "172.28.0.64/27"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "artifactory_integration_us_east_1e" {
  vpc_id                  = "${aws_vpc.artifactory_integration.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.28.0.96/27"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "artifactory_integration_us_east_1a_dmz" {
  vpc_id                  = "${aws_vpc.artifactory_integration.id}"
  availability_zone       = "us-east-1a"
  cidr_block              = "172.28.0.128/27"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "artifactory_integration_us_east_1c_dmz" {
  vpc_id                  = "${aws_vpc.artifactory_integration.id}"
  availability_zone       = "us-east-1c"
  cidr_block              = "172.28.0.160/27"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "artifactory_integration_us_east_1d_dmz" {
  vpc_id                  = "${aws_vpc.artifactory_integration.id}"
  availability_zone       = "us-east-1d"
  cidr_block              = "172.28.0.192/27"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "artifactory_integration_us_east_1e_dmz" {
  vpc_id                  = "${aws_vpc.artifactory_integration.id}"
  availability_zone       = "us-east-1e"
  cidr_block              = "172.28.0.224/27"
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
  subnet_id     = "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}"
}

resource "aws_route" "artifactory_integration_route" {
  route_table_id         = "${aws_vpc.artifactory_integration.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.artifactory_integration_nat_gw.id}"
}

resource "aws_route_table" "artifactory_integration_route_dmz" {
  vpc_id = "${aws_vpc.artifactory_integration.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.artifactory_integration_internet_gw.id}"
  }

  route {
    cidr_block                = "172.30.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.internal_apps_and_artifactory_integration_vpc_peering.id}"
  }

  route {
    cidr_block                = "172.27.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.pardot_ci_and_artifactory_integration_vpc_peering.id}"
  }
}

resource "aws_route" "artifactory_integration_to_pardot_ci" {
  destination_cidr_block    = "172.27.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.pardot_ci_and_artifactory_integration_vpc_peering.id}"
  route_table_id            = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route" "artifactory_integration_to_internal_apps" {
  destination_cidr_block    = "172.30.0.0/16"
  vpc_peering_connection_id = "${aws_vpc_peering_connection.internal_apps_and_artifactory_integration_vpc_peering.id}"
  route_table_id            = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1a" {
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1a.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1c" {
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1c.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1d" {
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1d.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1e" {
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1e.id}"
  route_table_id = "${aws_vpc.artifactory_integration.main_route_table_id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1a_dmz" {
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}"
  route_table_id = "${aws_route_table.artifactory_integration_route_dmz.id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1c_dmz" {
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1c_dmz.id}"
  route_table_id = "${aws_route_table.artifactory_integration_route_dmz.id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1d_dmz" {
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1d_dmz.id}"
  route_table_id = "${aws_route_table.artifactory_integration_route_dmz.id}"
}

resource "aws_route_table_association" "artifactory_integration_us_east_1e_dmz" {
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1e_dmz.id}"
  route_table_id = "${aws_route_table.artifactory_integration_route_dmz.id}"
}

resource "aws_security_group" "artifactory_integration_mysql_ingress" {
  name        = "artifactory_integration_mysql_ingress"
  description = "Allow mysql from artifactory instances only"
  vpc_id      = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_subnet.artifactory_integration_us_east_1a.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1a_dmz.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1c.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1c_dmz.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1d.cidr_block}",
      "${aws_subnet.artifactory_integration_us_east_1d_dmz.cidr_block}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "artifactory_integration" {
  name        = "artifactory_integration"
  description = "Pardot CI DB Subnet"

  subnet_ids = [
    "${aws_subnet.artifactory_integration_us_east_1a.id}",
    "${aws_subnet.artifactory_integration_us_east_1c.id}",
    "${aws_subnet.artifactory_integration_us_east_1d.id}",
    "${aws_subnet.artifactory_integration_us_east_1e.id}",
  ]
}

resource "aws_vpc_peering_connection" "internal_apps_and_artifactory_integration_vpc_peering" {
  peer_owner_id = "${var.pardotops_account_number}"
  peer_vpc_id   = "${aws_vpc.internal_apps.id}"
  vpc_id        = "${aws_vpc.artifactory_integration.id}"
}

resource "aws_vpc_peering_connection" "pardot_ci_and_artifactory_integration_vpc_peering" {
  peer_owner_id = "096113534078"
  peer_vpc_id   = "${var.pardot_ci_vpc_id}"
  vpc_id        = "${aws_vpc.artifactory_integration.id}"
}

resource "aws_route53_record" "artifactory_alb_dev_pardot_com_CNAME" {
  name    = "artifactory_alb.${aws_route53_zone.dev_pardot_com.name}"
  type    = "CNAME"
  zone_id = "${aws_route53_zone.dev_pardot_com.id}"
  records = ["${aws_alb.artifactory_public_alb.dns_name}"]
  ttl     = 900
}

resource "aws_alb" "artifactory_public_alb" {
  name     = "afy-pblc-alb-dev-pardot-com"
  internal = false

  security_groups = [
    "${aws_security_group.artifactory_dc_only_http_lb.id}",
    "${aws_security_group.artifactory_http_lb.id}",
  ]

  subnets = [
    "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1c_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1d_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1e_dmz.id}",
  ]
}

resource "aws_alb_target_group" "public_artifactory_all_hosts_target_group" {
  name     = "public-artifactory-host-tgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.artifactory_integration.id}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "86400"     #1 DAY
  }

  health_check {
    interval            = "60"
    path                = "/artifactory/api/system/ping"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    matcher             = "200"
  }
}

resource "aws_alb_listener" "public_alb_all_hosts_http" {
  load_balancer_arn = "${aws_alb.artifactory_public_alb.arn}"
  port              = 80
  protocol          = "HTTP"

  "default_action" {
    target_group_arn = "${aws_alb_target_group.public_artifactory_all_hosts_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "public_alb_all_hosts_https" {
  load_balancer_arn = "${aws_alb.artifactory_public_alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"

  "default_action" {
    target_group_arn = "${aws_alb_target_group.public_artifactory_all_hosts_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "public_pardot0-artifactory1-1-ue1_allhosts_attachment" {
  target_group_arn = "${aws_alb_target_group.public_artifactory_all_hosts_target_group.arn}"
  target_id        = "${aws_instance.pardot0-artifactory1-1-ue1.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "public_pardot0-artifactory1-2-ue1_allhosts_attachment" {
  target_group_arn = "${aws_alb_target_group.public_artifactory_all_hosts_target_group.arn}"
  target_id        = "${aws_instance.pardot0-artifactory1-2-ue1.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "public_pardot0-artifactory1-3-ue1_allhosts_attachment" {
  target_group_arn = "${aws_alb_target_group.public_artifactory_all_hosts_target_group.arn}"
  target_id        = "${aws_instance.pardot0-artifactory1-3-ue1.id}"
  port             = 80
}

resource "aws_alb" "artifactory_private_alb" {
  name     = "afy-prvt-alb-dev-pardot-com"
  internal = true

  security_groups = [
    "${aws_security_group.artifactory_http_lb_internal.id}",
  ]

  subnets = [
    "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1c_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1d_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1e_dmz.id}",
  ]
}

resource "aws_alb_target_group" "private_artifactory_all_hosts_target_group" {
  name     = "private-artifactory-host-tgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.artifactory_integration.id}"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "86400"     #1 DAY
  }

  health_check {
    interval            = "60"
    path                = "/artifactory/api/system/ping"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    matcher             = "200"
  }
}

resource "aws_alb_listener" "private_alb_all_hosts_http" {
  load_balancer_arn = "${aws_alb.artifactory_private_alb.arn}"
  port              = 80
  protocol          = "HTTP"

  "default_action" {
    target_group_arn = "${aws_alb_target_group.private_artifactory_all_hosts_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "private_alb_all_hosts_https" {
  load_balancer_arn = "${aws_alb.artifactory_private_alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"

  "default_action" {
    target_group_arn = "${aws_alb_target_group.private_artifactory_all_hosts_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "private_pardot0-artifactory1-1-ue1_allhosts_attachment" {
  target_group_arn = "${aws_alb_target_group.private_artifactory_all_hosts_target_group.arn}"
  target_id        = "${aws_instance.pardot0-artifactory1-1-ue1.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "private_pardot0-artifactory1-2-ue1_allhosts_attachment" {
  target_group_arn = "${aws_alb_target_group.private_artifactory_all_hosts_target_group.arn}"
  target_id        = "${aws_instance.pardot0-artifactory1-2-ue1.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "private_pardot0-artifactory1-3-ue1_allhosts_attachment" {
  target_group_arn = "${aws_alb_target_group.private_artifactory_all_hosts_target_group.arn}"
  target_id        = "${aws_instance.pardot0-artifactory1-3-ue1.id}"
  port             = 80
}

resource "aws_security_group" "artifactory_efs_access_security_group" {
  description = "artifactory_efs_access_security_group"
  vpc_id      = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    security_groups = [
      "${aws_security_group.artifactory_instance_secgroup.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name      = "artifactory_efs_storage"
    terraform = "true"
  }
}

resource "aws_efs_file_system" "artifactory_efs_storage" {
  tags {
    Name      = "artifactory_efs_storage"
    terraform = "true"
  }
}

resource "aws_efs_mount_target" "efs_mount_target_us_east_1a" {
  file_system_id = "${aws_efs_file_system.artifactory_efs_storage.id}"
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1a.id}"

  security_groups = [
    "${aws_security_group.artifactory_efs_access_security_group.id}",
  ]
}

resource "aws_efs_mount_target" "efs_mount_target_us_east_1c" {
  file_system_id = "${aws_efs_file_system.artifactory_efs_storage.id}"
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1c.id}"
}

resource "aws_efs_mount_target" "efs_mount_target_us_east_1d" {
  file_system_id = "${aws_efs_file_system.artifactory_efs_storage.id}"
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1d.id}"
}

resource "aws_efs_mount_target" "efs_mount_target_us_east_1e" {
  file_system_id = "${aws_efs_file_system.artifactory_efs_storage.id}"
  subnet_id      = "${aws_subnet.artifactory_integration_us_east_1e.id}"
}

#TODO: DELETE LEGACY AFTER SWITCHOVER IS FINAL
resource "aws_route53_record" "artifactory-origin_dev_pardot_com_Arecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "artifactory-legacy.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${var.legacy_artifactory_instance_ip}"]
  type    = "A"
  ttl     = "15"
}

resource "aws_route53_record" "artifactory-internal_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "artifactory-internal.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_elb.artifact_cache_lb.dns_name}"]
  type    = "CNAME"
  ttl     = "15"
}

resource "aws_route53_record" "artifactory-origin_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "artifactory-origin.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_alb.artifactory_private_alb.dns_name}"]
  type    = "CNAME"
  ttl     = "15"
}
