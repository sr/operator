resource "aws_security_group" "artifact_cache_http_lb" {
  name = "artifact_cache_http_lb"

  # description should read "Allow HTTP/HTTPS from Bamboo instances" but
  # changing it after the fact requires rebuilding all dependencies
  description = "Allow HTTP/HTTPS from SFDC VPN only"

  vpc_id = "${aws_vpc.artifactory_integration.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${var.pardot_ci_vpc_cidr}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_cookie_stickiness_policy" "duration-based-elb-cookie-policy-artifact-cache" {
  name                     = "duration-based-elb-cookie-policy-artifact-cache"
  load_balancer            = "${aws_elb.artifact_cache_lb.id}"
  lb_port                  = 443
  cookie_expiration_period = 3600
}

resource "aws_security_group" "external_artifact_cache_http_lb" {
  name        = "external_artifact_cache_http_lb"
  description = "Allow HTTP/HTTPS from SFDC VPN and datacenters only"
  vpc_id      = "${aws_vpc.artifactory_integration.id}"

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

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_eip.internal_apps_nat_gw.public_ip}/32",
      "${aws_eip.appdev_nat_gw.public_ip}/32",
      "${aws_eip.appdev_proxyout1_eip.public_ip}/32",
      "${aws_eip.artifactory_integration_nat_gw.public_ip}/32",
      "${var.pardot_ci_nat_gw_public_ip}/32",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "artifact_cache_server" {
  name        = "artifact_cache_server"
  description = "Allow HTTP from Artifact Cache LB"
  vpc_id      = "${aws_vpc.artifactory_integration.id}"

  # SSH from bastion
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.internal_apps_bastion.id}",
    ]
  }

  ingress = {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.artifact_cache_http_lb.id}",
      "${aws_security_group.external_artifact_cache_http_lb.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "artifact_cache_lb" {
  name            = "artifact-cache-lb"
  security_groups = ["${aws_security_group.artifact_cache_http_lb.id}"]

  subnets = [
    "${aws_subnet.artifactory_integration_us_east_1a.id}",
    "${aws_subnet.artifactory_integration_us_east_1c.id}",
    "${aws_subnet.artifactory_integration_us_east_1d.id}",
    "${aws_subnet.artifactory_integration_us_east_1e.id}",
  ]

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 30
  internal                    = true

  instances = [
    "${aws_instance.artifact_cache_server_1.id}",
    "${aws_instance.artifact_cache_server_2.id}",
    "${aws_instance.artifact_cache_server_3.id}",
    "${aws_instance.artifact_cache_server_4.id}",
  ]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 5
  }

  tags {
    Name = "internal-artifact-cache-lb"
  }
}

resource "aws_elb" "external_artifact_cache_lb" {
  name            = "external-artifact-cache-lb"
  security_groups = ["${aws_security_group.external_artifact_cache_http_lb.id}"]

  subnets = [
    "${aws_subnet.artifactory_integration_us_east_1a_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1c_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1d_dmz.id}",
    "${aws_subnet.artifactory_integration_us_east_1e_dmz.id}",
  ]

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 30

  instances = [
    "${aws_instance.artifact_cache_server_1.id}",
    "${aws_instance.artifact_cache_server_2.id}",
    "${aws_instance.artifact_cache_server_3.id}",
    "${aws_instance.artifact_cache_server_4.id}",
  ]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com-2016-with-intermediate"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 5
  }

  tags {
    Name = "external-artifact-cache-lb"
  }
}

resource "aws_instance" "artifact_cache_server_1" {
  ami                    = "${var.centos_6_hvm_ebs_ami}"
  instance_type          = "c4.2xlarge"
  subnet_id              = "${aws_subnet.artifactory_integration_us_east_1a.id}"
  vpc_security_group_ids = ["${aws_security_group.artifact_cache_server.id}"]
  key_name               = "internal_apps"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "512"
    delete_on_termination = true
  }

  tags {
    terraform = "true"
    Name      = "pardot0-artifactcache1-1-ue1"
  }
}

resource "aws_route53_record" "artifact_cache_server_1_Arecord" {
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-artifactcache1-1-ue1.${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.artifact_cache_server_1.private_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_instance" "artifact_cache_server_2" {
  ami                    = "${var.centos_6_hvm_ebs_ami}"
  instance_type          = "c4.2xlarge"
  subnet_id              = "${aws_subnet.artifactory_integration_us_east_1c.id}"
  vpc_security_group_ids = ["${aws_security_group.artifact_cache_server.id}"]
  key_name               = "internal_apps"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "512"
    delete_on_termination = true
  }

  tags {
    terraform = "true"
    Name      = "pardot0-artifactcache1-2-ue1"
  }
}

resource "aws_route53_record" "artifact_cache_server_2_Arecord" {
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-artifactcache1-2-ue1.${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.artifact_cache_server_2.private_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_instance" "artifact_cache_server_3" {
  ami                    = "${var.centos_6_hvm_ebs_ami}"
  instance_type          = "c4.2xlarge"
  subnet_id              = "${aws_subnet.artifactory_integration_us_east_1d.id}"
  vpc_security_group_ids = ["${aws_security_group.artifact_cache_server.id}"]
  key_name               = "internal_apps"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "512"
    delete_on_termination = true
  }

  tags {
    terraform = "true"
    Name      = "pardot0-artifactcache1-3-ue1"
  }
}

resource "aws_route53_record" "artifact_cache_server_3_Arecord" {
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-artifactcache1-3-ue1.${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.artifact_cache_server_3.private_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_instance" "artifact_cache_server_4" {
  ami                    = "${var.centos_6_hvm_ebs_ami}"
  instance_type          = "c4.2xlarge"
  subnet_id              = "${aws_subnet.artifactory_integration_us_east_1e.id}"
  vpc_security_group_ids = ["${aws_security_group.artifact_cache_server.id}"]
  key_name               = "internal_apps"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "512"
    delete_on_termination = true
  }

  tags {
    terraform = "true"
    Name      = "pardot0-artifactcache1-4-ue1"
  }
}

resource "aws_route53_record" "artifact_cache_server_4_Arecord" {
  zone_id = "${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-artifactcache1-4-ue1.${aws_route53_zone.internal_apps_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.artifact_cache_server_4.private_ip}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "artifactory_dev_pardot_com_CNAMErecord" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "artifactory.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_elb.external_artifact_cache_lb.dns_name}"]
  type    = "CNAME"
  ttl     = "900"
}
