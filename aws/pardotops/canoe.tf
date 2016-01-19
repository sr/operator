resource "aws_ecr_repository" "canoe" {
  name = "canoe"
}

resource "aws_ecs_cluster" "canoe_production" {
  name = "canoe_production"
}

resource "aws_elb" "canoe_production" {
  name = "canoe-production"
  security_groups = ["${aws_security_group.internal_apps_http_lb.id}"]
  subnets = [
    "${aws_subnet.internal_apps_us_east_1a_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1c_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1d_dmz.id}",
    "${aws_subnet.internal_apps_us_east_1e_dmz.id}"
  ]
  cross_zone_load_balancing = true
  connection_draining = true
  connection_draining_timeout = 30

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 80
    instance_protocol = "http"
    ssl_certificate_id = "arn:aws:iam::364709603225:server-certificate/dev.pardot.com"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 5
    target = "HTTP:80/_ping"
    interval = 30
  }

  tags {
    Name = "canoe_production"
  }
}
