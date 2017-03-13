resource "bamboo_build_plan" "BREAD-WAMJ" {
  key                   = "BREAD-WAMJ"
  name                  = "Artifactory Management Jobs"
  default_repository_id = "${bamboo_repository.bamboo-configuration.id}"
}

resource "bamboo_build_plan" "BREAD-BREAD" {
  key                   = "BREAD-BREAD"
  name                  = "bread"
  default_repository_id = "${bamboo_repository.bread.id}"
}

resource "bamboo_build_plan" "BREAD-CHEF" {
  key                   = "BREAD-CHEF"
  name                  = "Chef"
  default_repository_id = "${bamboo_repository.chef.id}"
}

resource "bamboo_build_plan" "BREAD-DJ" {
  key                   = "BREAD-DJ"
  name                  = "dailyjob"
  default_repository_id = "${bamboo_repository.bread.id}"
}

resource "bamboo_build_plan" "BREAD-DBI" {
  key                   = "BREAD-DBI"
  name                  = "Docker Base Images"
  default_repository_id = "${bamboo_repository.docker-library.id}"
}

resource "bamboo_build_plan" "BREAD-GITCLEAN" {
  key                   = "BREAD-GITCLEAN"
  name                  = "Git Cleanup"
  default_repository_id = "${bamboo_repository.bamboo-configuration.id}"
}

resource "bamboo_build_plan" "BREAD-INTAPI" {
  key                   = "BREAD-INTAPI"
  name                  = "Internal API"
  default_repository_id = "${bamboo_repository.internal-api.id}"
}

resource "bamboo_build_plan" "BREAD-MESH" {
  key                   = "BREAD-MESH"
  name                  = "Mesh"
  default_repository_id = "${bamboo_repository.mesh.id}"
}

resource "bamboo_build_plan" "BREAD-REPFIX" {
  key                   = "BREAD-REPFIX"
  name                  = "Repfix"
  default_repository_id = "${bamboo_repository.repfix.id}"
}

resource "bamboo_build_plan" "PDT-VAGRANT" {
  key                   = "PDT-VAGRANT"
  name                  = "vagrant-dev"
  default_repository_id = "${bamboo_repository.vagrant-dev.id}"
}
