variable "bamboo_username" {}

variable "bamboo_password" {}

variable "bamboo_git_username" {
  default = "sa_bamboo"
}

variable "bamboo_git_password" {}

provider "bamboo" {
  url      = "https://bamboo.dev.pardot.com"
  username = "${var.bamboo_username}"
  password = "${var.bamboo_password}"
}
