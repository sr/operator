variable "pardot_access_key_id" {}

variable "pardot_secret_access_key" {}

provider "aws" {
  access_key = "${var.pardot_access_key_id}"
  secret_key = "${var.pardot_secret_access_key}"
  region     = "us-east-1"
}
