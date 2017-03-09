variable "pardotatlassian_access_key_id" {}

variable "pardotatlassian_secret_access_key" {}

provider "aws" {
  access_key = "${var.pardotatlassian_access_key_id}"
  secret_key = "${var.pardotatlassian_secret_access_key}"
  region     = "us-east-1"
}
