//// App.dev environment clone template
//// managed by pd-bread@salesforce.com

////
//// CONFIGURATION
////

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
    num_job1_hosts = 1
    num_jobbackup1_hosts = 1
    num_thumbs1_hosts = 1
    num_redisjob1_hosts = 1
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
//// INFRASTRUCTURE
////

////
//// TEMPLATE: replace "lbl" w/ "servicename" and adjust instance_type upward if necessary
////
//resource "aws_instance" "appdev_lbl1" {
//  count = "${var.environment_appdev["num_lbl1_hosts"]}"
//  ami = "${var.centos_6_hvm_ebs_ami}"
//  instance_type = "${var.environment_appdev["app_instance_type}"
//  subnet_id = "${var.environment_appdev["subnet_id}"
//  security_groups = [
//    "${aws_security_group.appdev_default.id}"
//  ]
//  tags {
//    Name = "${var.environment_appdev["pardot_env_id"]}-lbl1-${count.index}-${var.environment_appdev["dc_id"]}"
//    terraform = "true"
//  }
//}
//
//resource "aws_eip" "appdev_lbl1" {
//  count = "${var.environment_appdev["num_lbl1_hosts"]}"
//  instance = "${element(aws_instance.appdev_lbl1.*.id, count.index)}"
//  vpc = true
//}

resource "aws_instance" "appdev_globaldb1" {
  count = "${var.environment_appdev["num_globaldb1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["db_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-globaldb1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_globaldb1" {
  count = "${var.environment_appdev["num_globaldb1_hosts"]}"
  instance = "${element(aws_instance.appdev_globaldb1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_dbshard1" {
  count = "${var.environment_appdev["num_dbshard1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["db_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-globaldb1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_dbshard1" {
  count = "${var.environment_appdev["num_dbshard1_hosts"]}"
  instance = "${element(aws_instance.appdev_dbshard1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_app1" {
  count = "${var.environment_appdev["num_app1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-app1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_app1" {
  count = "${var.environment_appdev["num_app1_hosts"]}"
  instance = "${element(aws_instance.appdev_app1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_job1" {
  count = "${var.environment_appdev["num_job1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["job_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-job1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_job1" {
  count = "${var.environment_appdev["num_job1_hosts"]}"
  instance = "${element(aws_instance.appdev_job1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_jobbackup1" {
  count = "${var.environment_appdev["num_jobbackup1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["job_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-jobbackup1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_jobbackup1" {
  count = "${var.environment_appdev["num_jobbackup1_hosts"]}"
  instance = "${element(aws_instance.appdev_jobbackup1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_thumbs1" {
  count = "${var.environment_appdev["num_thumbs1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-thumbs1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_thumbs1" {
  count = "${var.environment_appdev["num_thumbs1_hosts"]}"
  instance = "${element(aws_instance.appdev_thumbs1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_redisjob1" {
  count = "${var.environment_appdev["num_redisjob1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["job_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-redisjob1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_redisjob1" {
  count = "${var.environment_appdev["num_redisjob1_hosts"]}"
  instance = "${element(aws_instance.appdev_redisjob1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_jobmanager1" {
  count = "${var.environment_appdev["num_jobmanager1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-jobmanager1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_jobmanager1" {
  count = "${var.environment_appdev["num_jobmanager1_hosts"]}"
  instance = "${element(aws_instance.appdev_jobmanager1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_push1" {
  count = "${var.environment_appdev["num_push1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-push1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_push1" {
  count = "${var.environment_appdev["num_push1_hosts"]}"
  instance = "${element(aws_instance.appdev_push1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_provisioning1" {
  count = "${var.environment_appdev["num_provisioning1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-provisioning1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_provisioning1" {
  count = "${var.environment_appdev["num_provisioning1_hosts"]}"
  instance = "${element(aws_instance.appdev_provisioning1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_rabbit1" {
  count = "${var.environment_appdev["num_rabbit1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-rabbit1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_rabbit1" {
  count = "${var.environment_appdev["num_rabbit1_hosts"]}"
  instance = "${element(aws_instance.appdev_rabbit1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_redisrules1" {
  count = "${var.environment_appdev["num_redisrules1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-redisrules1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_redisrules1" {
  count = "${var.environment_appdev["num_redisrules1_hosts"]}"
  instance = "${element(aws_instance.appdev_redisrules1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_autojob1" {
  count = "${var.environment_appdev["num_autojob1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["job_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-autojob1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_autojob1" {
  count = "${var.environment_appdev["num_autojob1_hosts"]}"
  instance = "${element(aws_instance.appdev_autojob1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_storm1" {
  count = "${var.environment_appdev["num_storm1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-storm1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_storm1" {
  count = "${var.environment_appdev["num_storm1_hosts"]}"
  instance = "${element(aws_instance.appdev_storm1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_kafka1" {
  count = "${var.environment_appdev["num_kafka1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-kafka1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_kafka1" {
  count = "${var.environment_appdev["num_kafka1_hosts"]}"
  instance = "${element(aws_instance.appdev_kafka1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_zkkafka1" {
  count = "${var.environment_appdev["num_zkkafka1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-zkkafka1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}


resource "aws_eip" "appdev_zkkafka1" {
  count = "${var.environment_appdev["num_zkkafka1_hosts"]}"
  instance = "${element(aws_instance.appdev_zkkafka1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_pubsub1" {
  count = "${var.environment_appdev["num_pubsub1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-pubsub1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_pubsub1" {
  count = "${var.environment_appdev["num_pubsub1_hosts"]}"
  instance = "${element(aws_instance.appdev_pubsub1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_zkstorm1" {
  count = "${var.environment_appdev["num_zkstorm1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-zkstorm1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_zkstorm1" {
  count = "${var.environment_appdev["num_zkstorm1_hosts"]}"
  instance = "${element(aws_instance.appdev_zkstorm1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_nimbus1" {
  count = "${var.environment_appdev["num_nimbus1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-nimbus1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_nimbus1" {
  count = "${var.environment_appdev["num_nimbus1_hosts"]}"
  instance = "${element(aws_instance.appdev_nimbus1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_appcache1" {
  count = "${var.environment_appdev["num_appcache1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-appcache1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_appcache1" {
  count = "${var.environment_appdev["num_appcache1_hosts"]}"
  instance = "${element(aws_instance.appdev_appcache1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appdev_discovery1" {
  count = "${var.environment_appdev["num_discovery1_hosts"]}"
  ami = "${var.centos_6_hvm_ebs_ami}"
  instance_type = "${var.environment_appdev["app_instance_type"]}"
  subnet_id = "${aws_subnet.appdev_us_east_1d_dmz.id}}"
  security_groups = [
    "${aws_security_group.appdev_default.id}"
  ]
  tags {
    Name = "${var.environment_appdev["pardot_env_id"]}-discovery1-${count.index}-${var.environment_appdev["dc_id"]}"
    terraform = "true"
  }
}

resource "aws_eip" "appdev_discovery1" {
  count = "${var.environment_appdev["num_discovery1_hosts"]}"
  instance = "${element(aws_instance.appdev_discovery1.*.id, count.index)}"
  vpc = true
}