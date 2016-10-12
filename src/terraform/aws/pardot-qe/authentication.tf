variable "pardotqe_access_key_id" {}

variable "pardotqe_secret_access_key" {}

provider "aws" {
  access_key = "${var.pardotqe_access_key_id}"
  secret_key = "${var.pardotqe_secret_access_key}"
  region     = "us-east-1"
}
