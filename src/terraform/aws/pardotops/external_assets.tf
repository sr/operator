variable "pardot_ci_acct_number" {
  default = "364709603225"
}

variable "pardot_ci_vpc_id" {
  default = "vpc-9adc4bfd"
}

variable "pardot_ci_vpc_cidr" {
  default = "172.27.0.0/16"
}

variable "pardot_atlassian_acct_number" {
  default = "010094454891"
}

variable "pardot_atlassian_vpc_id" {
  default = "vpc-c35928a6"
}

////TODO: FILL THESE OUT WHEN <computed> and uncomment in artifact-cache.tf in pardotops
//variable "pardot2-artifactcache1-1-ue1_aws_pardot_com_public_ip" {
//  default = ""
//}
//
//variable "pardot2-artifactcache1-2-ue1_aws_pardot_com_public_ip" {
//  default = ""
//}
//
//variable "pardot2-artifactcache1-3-ue1_aws_pardot_com_public_ip" {
//  default = ""
//}
//
//variable "pardot2-artifactcache1-4-ue1_aws_pardot_com_public_ip" {
//  default = ""
//}
//
//variable "pardot2-artifactcache1-1-ue1_aws_pardot_com_private_ip" {
//  default = ""
//}
//
//variable "pardot2-artifactcache1-2-ue1_aws_pardot_com_private_ip" {
//  default = ""
//}
//
//variable "pardot2-artifactcache1-3-ue1_aws_pardot_com_private_ip" {
//  default = ""
//}
//
//variable "pardot2-artifactcache1-4-ue1_aws_pardot_com_private_ip" {
//  default = ""
//}