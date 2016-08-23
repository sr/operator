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
    "Resource": "arn:aws:ec2:eu-west-1:${var.pardot_ci_account_number}:instance/*",
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