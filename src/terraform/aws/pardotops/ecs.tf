variable "ecs_ami_id" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html
  default = "ami-3d55272a"
}

resource "aws_iam_role" "ecs_cluster_role" {
  name = "ecs_cluster_role"
  assume_role_policy = "${file("ec2_instance_trust_relationship.json")}"
}

resource "aws_iam_role_policy" "ecs_cluster_role_policy" {
  name = "ecs_cluster_role_policy"
  role = "${aws_iam_role.ecs_cluster_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.pardotops_configuration.bucket}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.pardotops_configuration.bucket}/production/ecs/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  roles = ["${aws_iam_role.ecs_cluster_role.id}"]
}
