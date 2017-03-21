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
  use_submodules = false
}

resource "bamboo_repository" "chef" {
  name                   = "chef"
  username               = "${var.bamboo_git_username}"
  password               = "${var.bamboo_git_password}"
  repository             = "Pardot/chef"
  shallow_clones         = false
  fetch_whole_repository = true
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

resource "bamboo_repository" "vagrant-dev" {
  name           = "vagrant-dev"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/vagrant-dev"
  shallow_clones = true
  use_submodules = false
}

resource "bamboo_repository" "symfony" {
  name           = "symfony"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/symfony"
  shallow_clones = true
}

resource "bamboo_repository" "bamboo-elastic-instance" {
  name           = "bamboo-elastic-instance"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/bamboo-elastic-instance"
  shallow_clones = true
}

resource "bamboo_repository" "symfony-dic" {
  name           = "symfony-dic"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/symfony-dic"
  shallow_clones = true
}

resource "bamboo_repository" "Discovery-Client" {
  name           = "Discovery-Client"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/Discovery-Client"
  shallow_clones = true
}

resource "bamboo_repository" "Discovery-Agent" {
  name           = "Discovery-Agent"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/Discovery-Agent"
  shallow_clones = true
}

resource "bamboo_repository" "java-snippets" {
  name           = "java-snippets"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/java-snippets"
  shallow_clones = true
}

resource "bamboo_repository" "php-amqplib" {
  name           = "php-amqplib"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/php-amqplib"
  shallow_clones = true
}

resource "bamboo_repository" "askeet" {
  name           = "askeet"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/askeet"
  shallow_clones = true
}

resource "bamboo_repository" "murda" {
  name           = "murda"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/murda"
  shallow_clones = true
}

resource "bamboo_repository" "all-the-bacon" {
  name           = "all-the-bacon"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/all-the-bacon"
  shallow_clones = true
}

resource "bamboo_repository" "kendo" {
  name           = "kendo"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/kendo"
  shallow_clones = true
}

resource "bamboo_repository" "SalesReachLicenseProvisioning" {
  name           = "SalesReachLicenseProvisioning"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/SalesReachLicenseProvisioning"
  shallow_clones = true
}

resource "bamboo_repository" "encryptionmanager" {
  name           = "encryptionmanager"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/encryptionmanager"
  shallow_clones = true
}

resource "bamboo_repository" "csrf-php" {
  name           = "csrf-php"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/csrf-php"
  shallow_clones = true
}

resource "bamboo_repository" "gmail-chrome" {
  name           = "gmail-chrome"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/gmail-chrome"
  shallow_clones = true
}

resource "bamboo_repository" "lead-deck-app" {
  name           = "lead-deck-app"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/lead-deck-app"
  shallow_clones = true
}

resource "bamboo_repository" "salesforce-demo-package" {
  name           = "salesforce-demo-package"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/salesforce-demo-package"
  shallow_clones = true
}

resource "bamboo_repository" "yubikey-ldap" {
  name           = "yubikey-ldap"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/yubikey-ldap"
  shallow_clones = true
}

resource "bamboo_repository" "breakout" {
  name           = "breakout"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/breakout"
  shallow_clones = true
}

resource "bamboo_repository" "SFdeploy" {
  name           = "SFdeploy"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/SFdeploy"
  shallow_clones = true
}

resource "bamboo_repository" "php-amqplib2" {
  name           = "php-amqplib2"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/php-amqplib2"
  shallow_clones = true
}

resource "bamboo_repository" "kb-articles" {
  name           = "kb-articles"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/kb-articles"
  shallow_clones = true
}

resource "bamboo_repository" "pd-homebrew" {
  name           = "pd-homebrew"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pd-homebrew"
  shallow_clones = true
}

resource "bamboo_repository" "ops-stacki" {
  name           = "ops-stacki"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/ops-stacki"
  shallow_clones = true
}

resource "bamboo_repository" "frame-js" {
  name           = "frame-js"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/frame-js"
  shallow_clones = true
}

resource "bamboo_repository" "ParMeter" {
  name           = "ParMeter"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/ParMeter"
  shallow_clones = true
}

resource "bamboo_repository" "rpms" {
  name           = "rpms"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/rpms"
  shallow_clones = true
}

resource "bamboo_repository" "mesh-sync-package" {
  name           = "mesh-sync-package"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/mesh-sync-package"
  shallow_clones = true
}

resource "bamboo_repository" "kendo-slds" {
  name           = "kendo-slds"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/kendo-slds"
  shallow_clones = true
}

resource "bamboo_repository" "pardot-demo-org-visualforce" {
  name           = "pardot-demo-org-visualforce"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pardot-demo-org-visualforce"
  shallow_clones = true
}

resource "bamboo_repository" "pardot-storm-example" {
  name           = "pardot-storm-example"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pardot-storm-example"
  shallow_clones = true
}

resource "bamboo_repository" "poor-mans-asset-pipeline" {
  name           = "poor-mans-asset-pipeline"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/poor-mans-asset-pipeline"
  shallow_clones = true
}

resource "bamboo_repository" "pcswg" {
  name           = "pcswg"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pcswg"
  shallow_clones = true
}

resource "bamboo_repository" "wave" {
  name           = "wave"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/wave"
  shallow_clones = true
}

resource "bamboo_repository" "crumb" {
  name           = "crumb"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/crumb"
  shallow_clones = true
}

resource "bamboo_repository" "kafka-tools" {
  name           = "kafka-tools"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/kafka-tools"
  shallow_clones = true
}

resource "bamboo_repository" "alert-dispatcher" {
  name           = "alert-dispatcher"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/alert-dispatcher"
  shallow_clones = true
}

resource "bamboo_repository" "wax" {
  name           = "wax"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/wax"
  shallow_clones = true
}

resource "bamboo_repository" "swiftmailer" {
  name           = "swiftmailer"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/swiftmailer"
  shallow_clones = true
}

resource "bamboo_repository" "pd-homebrew-php" {
  name           = "pd-homebrew-php"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pd-homebrew-php"
  shallow_clones = true
}

resource "bamboo_repository" "CumulusCI" {
  name           = "CumulusCI"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/CumulusCI"
  shallow_clones = true
}

resource "bamboo_repository" "pardot-es-parser" {
  name           = "pardot-es-parser"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/pardot-es-parser"
  shallow_clones = true
}

resource "bamboo_repository" "geoip-api-php" {
  name           = "geoip-api-php"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/geoip-api-php"
  shallow_clones = true
}

resource "bamboo_repository" "StormSupervisorValidationTool" {
  name           = "StormSupervisorValidationTool"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/StormSupervisorValidationTool"
  shallow_clones = true
}

resource "bamboo_repository" "salesforce-actions-topologies" {
  name           = "salesforce-actions-topologies"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/salesforce-actions-topologies"
  shallow_clones = true
}

resource "bamboo_repository" "redis-roaring" {
  name           = "redis-roaring"
  username       = "${var.bamboo_git_username}"
  password       = "${var.bamboo_git_password}"
  repository     = "Pardot/redis-roaring"
  shallow_clones = true
}
