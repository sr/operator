variable "pardotops_access_key_id" {}

variable "pardotops_secret_access_key" {}

provider "aws" {
  access_key = "${var.pardotops_access_key_id}"
  secret_key = "${var.pardotops_secret_access_key}"
  region     = "us-east-1"
}
