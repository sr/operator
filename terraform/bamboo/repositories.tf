resource "bamboo_repository" "ansible" {
  name           = "ansible"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/ansible"
  shallow_clones = true
}

resource "bamboo_repository" "bamboo-configuration" {
  name           = "bamboo-configuration"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/bamboo-configuration"
  shallow_clones = true
}

resource "bamboo_repository" "bamboo-configuration_develop-branch" {
  name           = "bamboo-configuration_develop-branch"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/bamboo-configuration"
  branch         = "develop"
  shallow_clones = true
}

resource "bamboo_repository" "blue-mesh" {
  name           = "blue-mesh"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/blue-mesh"
  shallow_clones = true
}

resource "bamboo_repository" "bread" {
  name           = "bread"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/bread"
  shallow_clones = false
}

resource "bamboo_repository" "chef" {
  name           = "chef"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/chef"
  shallow_clones = false
}

resource "bamboo_repository" "cimta-topology" {
  name           = "cimta-topology"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/cimta-topology"
  shallow_clones = true
}

resource "bamboo_repository" "docker-library" {
  name           = "docker-library"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/docker-library"
  shallow_clones = true
}

resource "bamboo_repository" "engage-campaign-reports" {
  name           = "engage-campaign-reports"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/engage-campaign-reports"
  shallow_clones = true
}

resource "bamboo_repository" "engagement-history-package" {
  name           = "engagement-history-package"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/engagement-history-package"
  shallow_clones = true
}

resource "bamboo_repository" "engagement-history-topology" {
  name           = "engagement-history-topology"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/engagement-history-topology"
  shallow_clones = true
}

resource "bamboo_repository" "engagement-studio" {
  name           = "engagement-studio"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/engagement-studio"
  shallow_clones = true
}

resource "bamboo_repository" "internal-api" {
  name           = "internal-api"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/internal-api"
  shallow_clones = true
}

resource "bamboo_repository" "mesh" {
  name           = "mesh"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/mesh"
  shallow_clones = true
}

resource "bamboo_repository" "murdoc" {
  name           = "murdoc"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/murdoc"
  shallow_clones = true
}

resource "bamboo_repository" "pardot" {
  name           = "pardot"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pardot"
  shallow_clones = true
}

resource "bamboo_repository" "pardot-java-models" {
  name           = "pardot-java-models"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pardot-java-models"
  shallow_clones = true
}

resource "bamboo_repository" "pardot-refocus" {
  name           = "pardot-refocus"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pardot-refocus"
  shallow_clones = true
}

resource "bamboo_repository" "pardot-storm" {
  name           = "pardot-storm"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pardot-storm"
  shallow_clones = true
}

resource "bamboo_repository" "pithumbs" {
  name           = "pithumbs"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pithumbs"
  shallow_clones = true
}

resource "bamboo_repository" "protobuf-schemas" {
  name           = "protobuf-schemas"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/protobuf-schemas"
  shallow_clones = true
}

resource "bamboo_repository" "provisioning-service" {
  name           = "provisioning-service"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/provisioning-service"
  shallow_clones = true
}

resource "bamboo_repository" "realtime-frontend" {
  name           = "realtime-frontend"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/realtime-frontend"
  shallow_clones = true
}

resource "bamboo_repository" "redis-monitor" {
  name           = "redis-monitor"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/redis-monitor"
  shallow_clones = true
}

resource "bamboo_repository" "repfix" {
  name           = "repfix"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/repfix"
  shallow_clones = true
}

resource "bamboo_repository" "rmux" {
  name           = "rmux"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/rmux"
  shallow_clones = true
}

resource "bamboo_repository" "salesforce-package" {
  name           = "salesforce-package"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/salesforce-package"
  shallow_clones = true
}

resource "bamboo_repository" "workflow-stats" {
  name           = "workflow-stats"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/workflow-stats"
  shallow_clones = true
}
