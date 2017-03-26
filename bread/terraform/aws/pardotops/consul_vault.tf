variable "environment_consul_vault" {
  type = "map"

  default = {
    pardot_env_id        = "pardot0"
    dc_id                = "ue1"
    consul_instance_type = "m4.large"
    vault_instance_type  = "m4.large"
    num_consul1_hosts    = 3
    num_vault1_hosts     = 2
  }
}

resource "aws_security_group" "pardot0_ue1_consul_vault" {
  name        = "pardot0_ue1_consul_vault"
  description = "Consul/Vault AWS pardot0 environment"
  vpc_id      = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # allow app.dev hosts access to vault port
  ingress {
    from_port = 8200
    to_port   = 8200
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.pardot0_ue1.cidr_block}",
      "${aws_eip.dc_access_00.public_ip}/32",
    ]

    security_groups = [
      "${aws_security_group.vault_http_lb.id}",
    ]
  }

  # allow app.dev hosts access to consul server port
  ingress {
    from_port = 8300
    to_port   = 8300
    protocol  = "tcp"

    cidr_blocks = [
      "${aws_vpc.pardot0_ue1.cidr_block}",
    ]
  }

  # SSH from bastion
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.pardot0_ue1_bastion.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "pardot0_ue1_consul1" {
  count         = "${var.environment_consul_vault["num_consul1_hosts"]}"
  ami           = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_consul_vault["consul_instance_type"]}"
  key_name      = "internal_apps"
  subnet_id     = "${aws_subnet.pardot0_ue1_1a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.pardot0_ue1_consul_vault.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = false
  }

  tags {
    Name      = "${var.environment_consul_vault["pardot_env_id"]}-consul1-${count.index + 1}-${var.environment_consul_vault["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_route53_record" "pardot0_ue1_consul1_Arecord" {
  count   = "${var.environment_consul_vault["num_consul1_hosts"]}"
  zone_id = "${aws_route53_zone.pardot0_ue1_aws_pardot_com_hosted_zone.zone_id}"
  name    = "${var.environment_consul_vault["pardot_env_id"]}-consul1-${count.index + 1}-${var.environment_consul_vault["dc_id"]}.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${element(aws_instance.pardot0_ue1_consul1.*.private_ip, count.index)}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_instance" "pardot0_ue1_vault1" {
  count         = "${var.environment_consul_vault["num_vault1_hosts"]}"
  ami           = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_consul_vault["vault_instance_type"]}"
  key_name      = "internal_apps"
  subnet_id     = "${aws_subnet.pardot0_ue1_1a.id}"

  vpc_security_group_ids = [
    "${aws_security_group.pardot0_ue1_consul_vault.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = false
  }

  tags {
    Name      = "${var.environment_consul_vault["pardot_env_id"]}-vault1-${count.index + 1}-${var.environment_consul_vault["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_route53_record" "pardot0_ue1_vault1_Arecord" {
  count   = "${var.environment_consul_vault["num_vault1_hosts"]}"
  zone_id = "${aws_route53_zone.pardot0_ue1_aws_pardot_com_hosted_zone.zone_id}"
  name    = "${var.environment_consul_vault["pardot_env_id"]}-vault1-${count.index + 1}-${var.environment_consul_vault["dc_id"]}.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${element(aws_instance.pardot0_ue1_vault1.*.private_ip, count.index)}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_route53_record" "vault_dev_pardot_com_CNAME_record" {
  zone_id = "${aws_route53_zone.dev_pardot_com.zone_id}"
  name    = "vault.${aws_route53_zone.dev_pardot_com.name}"
  records = ["${aws_elb.vault_public_elb.dns_name}"]
  type    = "CNAME"
  ttl     = "900"
}

resource "aws_security_group" "vault_http_lb" {
  name        = "vault_http_lb"
  description = "Allow HTTP/HTTPS from SFDC VPN and CI"
  vpc_id      = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${var.pardot_ci_nat_gw_public_ip}/32",
    ]

    self = "true"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "vault_public_elb" {
  security_groups = [
    "${aws_security_group.vault_http_lb.id}",
  ]

  subnets = [
    "${aws_subnet.pardot0_ue1_1a_dmz.id}",
    "${aws_subnet.pardot0_ue1_1c_dmz.id}",
    "${aws_subnet.pardot0_ue1_1d_dmz.id}",
    "${aws_subnet.pardot0_ue1_1e_dmz.id}",
  ]

  connection_draining         = true
  connection_draining_timeout = 30
  instances                   = ["${aws_instance.pardot0_ue1_vault1.*.id}"]

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 8200
    instance_protocol  = "https"
    ssl_certificate_id = "arn:aws:iam::${var.pardotops_account_number}:server-certificate/dev.pardot.com-2017-with-intermediate"
  }

  health_check {
    healthy_threshold   = 4
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTPS:8200/v1/sys/health"
    interval            = 10
  }

  tags {
    Name = "vault_elb"
  }
}
