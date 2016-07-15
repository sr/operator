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
//resource "aws_instance" "lbl1" {
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
//resource "aws_eip" "lbl1" {
//  count = "${var.environment_appdev["num_lbl1_hosts"]}"
//  instance = "${element(aws_instance.lbl1.*.id, count.index)}"
//  vpc = true
//}

resource "aws_instance" "globaldb1" {
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

resource "aws_eip" "globaldb1" {
  count = "${var.environment_appdev["num_globaldb1_hosts"]}"
  instance = "${element(aws_instance.globaldb1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "dbshard1" {
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

resource "aws_eip" "dbshard1" {
  count = "${var.environment_appdev["num_dbshard1_hosts"]}"
  instance = "${element(aws_instance.dbshard1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "app1" {
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

resource "aws_eip" "app1" {
  count = "${var.environment_appdev["num_app1_hosts"]}"
  instance = "${element(aws_instance.app1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "job1" {
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

resource "aws_eip" "job1" {
  count = "${var.environment_appdev["num_job1_hosts"]}"
  instance = "${element(aws_instance.job1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "jobbackup1" {
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

resource "aws_eip" "jobbackup1" {
  count = "${var.environment_appdev["num_jobbackup1_hosts"]}"
  instance = "${element(aws_instance.jobbackup1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "thumbs1" {
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

resource "aws_eip" "thumbs1" {
  count = "${var.environment_appdev["num_thumbs1_hosts"]}"
  instance = "${element(aws_instance.thumbs1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "redisjob1" {
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

resource "aws_eip" "redisjob1" {
  count = "${var.environment_appdev["num_redisjob1_hosts"]}"
  instance = "${element(aws_instance.redisjob1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "jobmanager1" {
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

resource "aws_eip" "jobmanager1" {
  count = "${var.environment_appdev["num_jobmanager1_hosts"]}"
  instance = "${element(aws_instance.jobmanager1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "push1" {
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

resource "aws_eip" "push1" {
  count = "${var.environment_appdev["num_push1_hosts"]}"
  instance = "${element(aws_instance.push1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "provisioning1" {
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

resource "aws_eip" "provisioning1" {
  count = "${var.environment_appdev["num_provisioning1_hosts"]}"
  instance = "${element(aws_instance.provisioning1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "rabbit1" {
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

resource "aws_eip" "rabbit1" {
  count = "${var.environment_appdev["num_rabbit1_hosts"]}"
  instance = "${element(aws_instance.rabbit1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "redisrules1" {
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

resource "aws_eip" "redisrules1" {
  count = "${var.environment_appdev["num_redisrules1_hosts"]}"
  instance = "${element(aws_instance.redisrules1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "autojob1" {
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

resource "aws_eip" "autojob1" {
  count = "${var.environment_appdev["num_autojob1_hosts"]}"
  instance = "${element(aws_instance.autojob1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "storm1" {
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

resource "aws_eip" "storm1" {
  count = "${var.environment_appdev["num_storm1_hosts"]}"
  instance = "${element(aws_instance.storm1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "kafka1" {
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

resource "aws_eip" "kafka1" {
  count = "${var.environment_appdev["num_kafka1_hosts"]}"
  instance = "${element(aws_instance.kafka1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "zkkafka1" {
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


resource "aws_eip" "zkkafka1" {
  count = "${var.environment_appdev["num_zkkafka1_hosts"]}"
  instance = "${element(aws_instance.zkkafka1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "pubsub1" {
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

resource "aws_eip" "pubsub1" {
  count = "${var.environment_appdev["num_pubsub1_hosts"]}"
  instance = "${element(aws_instance.pubsub1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "zkstorm1" {
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

resource "aws_eip" "zkstorm1" {
  count = "${var.environment_appdev["num_zkstorm1_hosts"]}"
  instance = "${element(aws_instance.zkstorm1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "nimbus1" {
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

resource "aws_eip" "nimbus1" {
  count = "${var.environment_appdev["num_nimbus1_hosts"]}"
  instance = "${element(aws_instance.nimbus1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "appcache1" {
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

resource "aws_eip" "appcache1" {
  count = "${var.environment_appdev["num_appcache1_hosts"]}"
  instance = "${element(aws_instance.appcache1.*.id, count.index)}"
  vpc = true
}

resource "aws_instance" "discovery1" {
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

resource "aws_eip" "discovery1" {
  count = "${var.environment_appdev["num_discovery1_hosts"]}"
  instance = "${element(aws_instance.discovery1.*.id, count.index)}"
  vpc = true
}