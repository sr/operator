# DO NOT DELETE until NetSec has removed 52.3.71.92 from our toolsproxy
# firewall. Otherwise, this IP could be allocated to a different AWS customer
# and used to access toolsproxy.
resource "aws_eip" "tools_egress_proxy" {
  vpc = true
}
