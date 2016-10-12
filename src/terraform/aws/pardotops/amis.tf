variable "amazon_linux_hvm_ebs_ami" {
  default = "ami-08111162"
}

variable "centos_6_hvm_ebs_ami" {
  default = "ami-1c221e76"
}

variable "centos_7_hvm_ebs_ami" {
  default = "ami-6d1c2007"
}

variable "centos_6_hvm_50gb_chefdev_ami" {
  default = "ami-f069f8e7" #prev: ami-c1af3ad6
}

variable "centos_7_hvm_50gb_chefdev_ami" {
  default = "ami-b883c8af"
}

variable "centos_6_hvm_50gb_chefdev_ami_LDAP_AUTH_HOST_ONLY" {
  default = "ami-c1af3ad6"
}

variable "centos_7_hvm_ebs_ami_2TB_ENH_NTWK_CHEF_UE1_PROD_AFY_ONLY" {
  default = "ami-00bcd817" # CentOS 7 with Updates / Enhanced Networking / 2TB / Production Chef Bootstrap Ready
}