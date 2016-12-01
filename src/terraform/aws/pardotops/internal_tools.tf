// Internal tools include production-level services we use to support our
// internal development. Examples include JIRA and HipChat.
resource "aws_security_group" "hipchat_server_admin_management" {
  name   = "hipchat_server_admin_management"
  vpc_id = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    security_groups = [
      "${aws_security_group.github_enterprise_server_backups.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hipchat_server_xmpp" {
  name   = "hipchat_server_xmpp"
  vpc_id = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port = 5222
    to_port   = 5223
    protocol  = "tcp"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
      "${var.sfdc_proxyout_cidr_blocks}",
      "${aws_nat_gateway.pardot0_ue1_nat_gw.public_ip}/32",
      "${var.sfdc_pardot_tools_production_heroku_space_cidr_blocks}",
      "${var.sfdc_pardot_tools_netherworld_heroku_space_cidr_blocks}",
      "${var.bamboo_server_instance_ip}/32",
      "${var.confluence_server_instance_ip}/32",
      "${var.pardot_ci_nat_gw_public_ip}/32",
      "${var.jira_server_instance_ip}/32",
      "${var.tools_egress_proxy_ip}/32",
      "${aws_instance.github_enterprise_server_1.public_ip}/32",
      "${aws_instance.github_enterprise_server_2.public_ip}/32",
      "52.0.199.236/32",                                               # bots.dev.pardot.com
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hipchat_server_http" {
  name   = "hipchat_server_http"
  vpc_id = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
      "${var.sfdc_proxyout_cidr_blocks}",
      "${aws_nat_gateway.pardot0_ue1_nat_gw.public_ip}/32",
      "${var.sfdc_pardot_tools_production_heroku_space_cidr_blocks}",
      "${var.sfdc_pardot_tools_netherworld_heroku_space_cidr_blocks}",
      "${var.bamboo_server_instance_ip}/32",
      "${var.confluence_server_instance_ip}/32",
      "${var.pardot_ci_nat_gw_public_ip}/32",
      "${var.jira_server_instance_ip}/32",
      "${var.tools_egress_proxy_ip}/32",
      "${aws_instance.github_enterprise_server_1.public_ip}/32",
      "${aws_instance.github_enterprise_server_2.public_ip}/32",
      "52.0.199.236/32",                                               # bots.dev.pardot.com
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hipchat_server_https" {
  name   = "hipchat_server_https"
  vpc_id = "${aws_vpc.pardot0_ue1.id}"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "${var.aloha_vpn_cidr_blocks}",
      "${var.sfdc_proxyout_cidr_blocks}",
      "${aws_nat_gateway.pardot0_ue1_nat_gw.public_ip}/32",
      "${var.sfdc_pardot_tools_production_heroku_space_cidr_blocks}",
      "${var.sfdc_pardot_tools_netherworld_heroku_space_cidr_blocks}",
      "${var.bamboo_server_instance_ip}/32",
      "${var.confluence_server_instance_ip}/32",
      "${var.pardot_ci_nat_gw_public_ip}/32",
      "${var.jira_server_instance_ip}/32",
      "${var.tools_egress_proxy_ip}/32",
      "${aws_instance.github_enterprise_server_1.public_ip}/32",
      "${aws_instance.github_enterprise_server_2.public_ip}/32",
      "52.0.199.236/32",                                               # bots.dev.pardot.com
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "hipchat_server" {
  ami                     = "ami-TODO"
  instance_type           = "c4.2xlarge"
  key_name                = "hipchat"
  subnet_id               = "${aws_subnet.pardot0_ue1_1e_dmz.id}"
  disable_api_termination = true
  ebs_optimized           = true

  vpc_security_group_ids = [
    "${aws_security_group.hipchat_server_admin_management.id}",
    "${aws_security_group.hipchat_server_xmpp.id}",
    "${aws_security_group.hipchat_server_http.id}",
    "${aws_security_group.hipchat_server_https.id}",
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "250"
    delete_on_termination = false
  }

  tags {
    Name      = "pardot0-hipchat1-1-ue1"
    terraform = "true"
  }
}

resource "aws_eip" "hipchat_server" {
  vpc      = true
  instance = "${aws_instance.hipchat_server.id}"
}

resource "aws_route53_record" "hipchat_server_Arecord" {
  zone_id = "${aws_route53_zone.pardot0_ue1_aws_pardot_com_hosted_zone.zone_id}"
  name    = "pardot0-hipchat1-1-ue1.${aws_route53_zone.pardot0_ue1_aws_pardot_com_hosted_zone.name}"
  records = ["${aws_instance.hipchat_server.private_ip}"]
  type    = "A"
  ttl     = "900"
}
