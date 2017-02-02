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
      "${aws_eip.pardot0_ue1_nat_gw.public_ip}/32",
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
  subnet_id     = "${aws_subnet.pardot0_ue1_1a_dmz.id}"

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
  subnet_id     = "${aws_subnet.pardot0_ue1_1a_dmz.id}"

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
