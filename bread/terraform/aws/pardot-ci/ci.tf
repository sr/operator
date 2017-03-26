# Account for bamboo.dev.pardot.com to spin up and manage instances
resource "aws_iam_user" "bamboo_sysacct" {
  name = "bamboo_sysacct"
}

resource "aws_iam_user_policy" "bamboo_sysacct_access_rights" {
  name = "BambooServerSysAcctPolicy"
  user = "${aws_iam_user.bamboo_sysacct.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Sid": "BambooAllowedAll",
    "Effect": "Allow",
    "Action": [
        "ec2:Describe*",
        "ec2:RequestSpot*",
        "ec2:CancelSpot*",
        "ec2:AllocateAddress",
        "ec2:AssociateAddress",
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CancelSpotInstanceRequests",
        "ec2:CreateKeyPair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:DescribeAddresses",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotInstanceRequests",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets",
        "ec2:DescribeVolumes",
        "ec2:DescribeVpcs",
        "ec2:GetConsoleOutput",
        "ec2:ModifyInstanceAttribute",
        "ec2:ReleaseAddress",
        "ec2:RequestSpotInstances",
        "ec2:RunInstances"
    ],
    "Resource": "*"
  },
  {
    "Sid": "BambooAllowedOnlyOnCreated",
    "Effect": "Allow",
    "Action": [
        "ec2:TerminateInstances",
        "ec2:StopInstances",
        "ec2:StartInstances"
    ],
    "Resource": "arn:aws:ec2:us-east-1:${var.pardot_ci_account_number}:instance/*",
    "Condition": {
        "StringEquals": {
            "ec2:ResourceTag/Name": "bam::bamboo.dev.pardot.com::bamboo"
        }
    }
  }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "bamboo_worker" {
  name  = "bamboo_worker"
  roles = ["${aws_iam_role.bamboo_worker.id}"]
}

# Bamboo workers may spin up additional EC2 machines in the pardot-ci account
# https://www.packer.io/docs/builders/amazon.html
resource "aws_iam_role" "bamboo_worker" {
  name = "bamboo_worker"

  assume_role_policy = "${file("ec2_instance_trust_relationship.json")}"
}

resource "aws_iam_role_policy" "bamboo_worker" {
  name = "bamboo_worker"
  role = "${aws_iam_role.bamboo_worker.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeypair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource" : "*"
  }]
}
EOF
}
