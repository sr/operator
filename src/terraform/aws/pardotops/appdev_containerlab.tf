resource "aws_instance" "appdev_cljobmanager1" {
  key_name      = "internal_apps"
  count         = 1
  ami           = "${var.centos_7_hvm_50gb_chefdev_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id     = "${aws_subnet.appdev_us_east_1d.id}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}",
  ]

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-cljobmanager1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_route53_record" "appdev_cljobmanager1_arecord" {
  count   = 1
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "${var.environment_appdev["pardot_env_id"]}-cljobmanager1-${count.index + 1}-${var.environment_appdev["dc_id"]}.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${element(aws_instance.appdev_cljobmanager1.*.private_ip, count.index)}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_instance" "appdev_clredisjob1" {
  key_name      = "internal_apps"
  count         = 1
  ami           = "${var.centos_7_hvm_50gb_chefdev_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id     = "${aws_subnet.appdev_us_east_1d.id}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}",
  ]

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-clredisjob1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_route53_record" "appdev_clredisjob1_arecord" {
  count   = 1
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "${var.environment_appdev["pardot_env_id"]}-clredisjob1-${count.index + 1}-${var.environment_appdev["dc_id"]}.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${element(aws_instance.appdev_clredisjob1.*.private_ip, count.index)}"]
  type    = "A"
  ttl     = "900"
}

resource "aws_instance" "appdev_cledgecache1" {
  key_name      = "internal_apps"
  count         = 1
  ami           = "${var.centos_7_hvm_50gb_chefdev_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id     = "${aws_subnet.appdev_us_east_1d.id}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }

  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}",
  ]

  tags {
    Name      = "${var.environment_appdev["pardot_env_id"]}-cledgecache1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_route53_record" "appdev_cledgecache1_arecord" {
  count   = 1
  zone_id = "${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.zone_id}"
  name    = "${var.environment_appdev["pardot_env_id"]}-cledgecache1-${count.index + 1}-${var.environment_appdev["dc_id"]}.${aws_route53_zone.appdev_aws_pardot_com_hosted_zone.name}"
  records = ["${element(aws_instance.appdev_cledgecache1.*.private_ip, count.index)}"]
  type    = "A"
  ttl     = "900"
}
