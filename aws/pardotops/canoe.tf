resource "aws_ecr_repository" "canoe" {
  name = "canoe"
}

resource "aws_iam_role" "canoe_ec2_role" {
  name = "canoe_ec2_role"
  assume_role_policy = "${file(\"ec2_instance_trust_relationship.json\")}"
}

resource "aws_iam_role_policy" "canoe_ec2_ecs_service_policy" {
  name = "canoe_ec2_ecs_service_policy"
  role = "${aws_iam_role.canoe_ec2_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "canoe_ec2_instance_profile" {
  name = "canoe_ec2_instance_profile"
  roles = ["${aws_iam_role.canoe_ec2_role.name}"]
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
