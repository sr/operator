resource "bamboo_build_plan" "BREAD-BREAD" {
  key                   = "BREAD-BREAD"
  name                  = "bread"
  default_repository_id = "${bamboo_repository.bread.id}"
}

resource "bamboo_build_plan" "PDT-VAGRANT" {
  key                   = "PDT-VAGRANT"
  name                  = "vagrant-dev"
  default_repository_id = "${bamboo_repository.vagrant-dev.id}"
}
