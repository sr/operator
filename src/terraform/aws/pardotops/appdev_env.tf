//// App.dev environment
//// managed by pd-bread@salesforce.com


variable "environment_appdev" {
  type = "map"

  default = {
    env_name = "appdev"
    pardot_env_id = "pardot2"
    dc_id = "ue1"
    app_instance_type = "m4.large"
    job_instance_type = "m4.large"
    db_instance_type = "m4.2xlarge"
    num_globaldb1_hosts = 2
    num_dbshard1_hosts = 4
    num_app1_hosts = 2
    num_thumbs1_hosts = 1
    num_redisjob1_hosts = 2
    num_jobmanager1_hosts = 2
    num_push1_hosts = 2
    num_provisioning1_hosts = 1
    num_rabbit1_hosts = 3
    num_redisrules1_hosts = 2
    num_autojob1_hosts = 1
    num_storm1_hosts = 1
    num_kafka1_hosts = 1
    num_zkkafka1_hosts = 1
    num_pubsub1_hosts = 2
    num_zkstorm1_hosts = 3
    num_nimbus1_hosts = 1
    num_appcache1_hosts = 2
    num_discovery1_hosts = 3
  }
}


////
//// TEMPLATES
////
//
//// EC2 INSTANCE: replace "lbl" w/ "servicename", edit secgroups accordingly, and adjust instance_type upward if necessary
//resource "aws_instance" "appdev_lbl1" {
//  key_name = "internal_apps"
//  count = "${var.environment_appdev["num_lbl1_hosts"]}"
//  ami = "${var.centos_6_hvm_ebs_ami}"
//  instance_type = "${var.environment_appdev["app_instance_type}"
//  subnet_id = "${var.environment_appdev["subnet_id}"
//  vpc_security_group_ids = [
//    "${aws_security_group.appdev_vpc_default.id}",
//    "${aws_security_group.appdev_dbhost.id}",
//    "${aws_security_group.appdev_apphost.id}"
//  ]
//  tags {
//    Name = "${var.environment_appdev["pardot_env_id"]}-lbl1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
//    terraform = "true"
//  }
//}
//
//// EC2 ELASTIC IP: replace "lbl" w/ "servicename"
//resource "aws_eip" "appdev_lbl1" {
//  count = "${var.environment_appdev["num_lbl1_hosts"]}"
//  instance = "${element(aws_instance.appdev_lbl1.*.id, count.index)}"
//  vpc = true
//}

resource "aws_security_group" "appdev_apphost" {
  name = "appdev_apphost"
  description = "Allow HTTP/HTTPS traffic from appdev vpc"
  vpc_id = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups= [
      "${self}"
    ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}"
    ]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "${aws_vpc.appdev.cidr_block}"
    ]
  }

  # allow health check from ELBs
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.appdev_sfdc_vpn_http_https.id}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "appdev_dbhost" {
  name = "appdev_dbhost"
  description = "Allow MYSQL traffic from appdev apphosts"
  vpc_id = "${aws_vpc.appdev.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.appdev_apphost.id}"
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "appdev_app_elb" {
  name = "${var.environment_appdev["env_name"]}-app-elb"
  security_groups = [
    "${aws_security_group.appdev_sfdc_vpn_http_https.id}"
  ]
  subnets = [
    "${aws_subnet.appdev_us_east_1a.id}",
    "${aws_subnet.appdev_us_east_1c.id}",
    "${aws_subnet.appdev_us_east_1d.id}",
    "${aws_subnet.appdev_us_east_1e.id}"
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 30
  instances = ["${element(aws_instance.appdev_app1.*.id, count.index)}"]

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 80
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::${var.pardotops_account_number}:server-certificate/dev.pardot.com-2016-with-intermediate"
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
    target = "HTTP:80/home/ping"
    interval = 5
  }

  tags {
    Name = "appdev_public_elb"
  }
}

resource "aws_instance" "appdev_globaldb1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_globaldb1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["db_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}",
    "${aws_security_group.appdev_dbhost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-globaldb1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_dbshard1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_dbshard1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["db_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}",
    "${aws_security_group.appdev_dbhost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-globaldb1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_app1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_app1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-app1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_thumbs1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_thumbs1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-thumbs1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_redisjob1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_redisjob1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["job_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-redisjob1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_jobmanager1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_jobmanager1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-jobmanager1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_push1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_push1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-push1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_provisioning1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_provisioning1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-provisioning1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_rabbit1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_rabbit1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-rabbit1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_redisrules1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_redisrules1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-redisrules1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_autojob1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_autojob1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["job_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-autojob1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_storm1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_storm1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-storm1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_kafka1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_kafka1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-kafka1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_zkkafka1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_zkkafka1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-zkkafka1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_pubsub1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_pubsub1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-pubsub1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_zkstorm1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_zkstorm1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-zkstorm1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_nimbus1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_nimbus1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-nimbus1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_appcache1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_appcache1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-appcache1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_instance" "appdev_discovery1" {
  key_name = "internal_apps"
  count = "${var.environment_appdev["num_discovery1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}"
  vpc_security_group_ids = [
    "${aws_security_group.appdev_vpc_default.id}",
    "${aws_security_group.appdev_apphost.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-discovery1-${count.index + 1}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}
