resource "aws_ecr_repository" "canoe" {
  name = "canoe"
}

resource "aws_iam_role" "canoe_ec2_role" {
  name = "canoe_ec2_role"
  assume_role_policy = "${file(\"ec2_instance_trust_relationship.json\")}"
}

resource "aws_iam_role_policy" "canoe_ec2_ecs_role_policy" {
  name = "canoe_ecs_role_policy"
  role = "${aws_iam_role.canoe_ec2_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:StartTask",
        "ecs:StopTask",
        "ecs:RegisterContainerInstance",
        "ecs:DeregisterContainerInstance",
        "ecs:DescribeContainerInstances",
        "ecs:DiscoverPollEndpoint",
        "ecs:Submit*",
        "ecs:Poll"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::elasticbeanstalk-*/resources/environments/logs/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "canoe_ec2_ecr_role_policy" {
  name = "canoe_ecr_role_policy"
  role = "${aws_iam_role.canoe_ec2_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "canoe_ec2_instance_profile" {
  name = "canoe_ec2_instance_profile"
  roles = ["${aws_iam_role.canoe_ec2_role.name}"]
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
