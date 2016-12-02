variable "pardotops_access_key_id" {}

variable "pardotops_secret_access_key" {}

variable "letsencrypt_api_url" {
  type    = "string"
  default = "https://acme-staging.api.letsencrypt.org/directory"
}

variable "letsencrypt_registration_email" {
  type    = "string"
  default = "pd-bread@salesforce.com"
}

resource "tls_private_key" "bread_registration_private_key" {
  algorithm = "RSA"
}

resource "tls_private_key" "bread_cert_private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "bread" {
  server_url      = "${var.letsencrypt_api_url}"
  account_key_pem = "${tls_private_key.bread_registration_private_key.private_key_pem}"
  email_address   = "${letsencrypt_registration_email}"
}

resource "tls_cert_request" "compliance_dev_pardot_com" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.bread_cert_private_key.private_key_pem}"
  dns_names       = ["compliance.dev.pardot.com"]

  subject {
    common_name = "compliance.dev.pardot.com"
  }
}

resource "acme_certificate" "compliance_dev_pardot_com" {
  server_url              = "${var.letsencrypt_api_url}"
  account_key_pem         = "${tls_private_key.bread_registration_private_key.private_key_pem}"
  certificate_request_pem = "${tls_cert_request.compliance_dev_pardot_com.cert_request_pem}"

  dns_challenge {
    provider = "route53"

    config {
      AWS_ACCESS_KEY_ID     = "${var.pardotops_access_key_id}"
      AWS_SECRET_ACCESS_KEY = "${var.pardotops_secret_access_key}"
      AWS_DEFAULT_REGION    = "us-east-1"
    }
  }

  registration_url = "${acme_registration.bread.id}"
}