variable "pardotops_access_key_id" {
}

variable "pardotops_secret_access_key" {
}

variable "dyn_customer_name" {
}

variable "dyn_username" {
}

variable "dyn_password" {
}

provider "aws" {
  access_key = "${var.pardotops_access_key_id}"
  secret_key = "${var.pardotops_secret_access_key}"
  region = "us-east-1"
}

provider "dyn" {
  customer_name = "${var.dyn_customer_name}"
  username = "${var.dyn_username}"
  password = "${var.dyn_password}"
}