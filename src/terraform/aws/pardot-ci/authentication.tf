variable "pardotci_access_key_id" {
}

variable "pardotci_secret_access_key" {
}

provider "aws" {
  access_key = "${var.pardotci_access_key_id}"
  secret_key = "${var.pardotci_secret_access_key}"
  region = "us-east-1"
}
