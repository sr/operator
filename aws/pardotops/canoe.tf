resource "aws_ecr_repository" "canoe" {
  name = "canoe"
}

resource "aws_iam_user_policy" "sa_bamboo_push_pull_canoe_ecr" {
  name = "sa_bamboo_push_pull_canoe_ecr"
  user = "${aws_iam_user.sa_bamboo.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "*"
    }
  ]
}
EOF
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

resource "aws_ecs_cluster" "canoe_production" {
  name = "canoe_production"
}

resource "aws_launch_configuration" "canoe_production" {
  name_prefix = "canoe_production"
  image_id = "${var.ecs_ami_id}"
  instance_type = "t2.small"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance_profile.id}"
  associate_public_ip_address = false

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=canoe_production >> /etc/ecs/ecs.config
EOF

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "canoe_production" {
  max_size = 2
  min_size = 2
  launch_configuration = "${aws_launch_configuration.canoe_production.id}"
  vpc_zone_identifier = [
    "${aws_subnet.internal_apps_us_east_1a.id}",
    "${aws_subnet.internal_apps_us_east_1c.id}",
    "${aws_subnet.internal_apps_us_east_1d.id}",
    "${aws_subnet.internal_apps_us_east_1e.id}"
  ]

  lifecycle {
    create_before_destroy = true
  }
}
