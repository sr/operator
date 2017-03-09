resource "bamboo_repository" "bread" {
  name           = "bread"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/bread"
  shallow_clones = false
}
