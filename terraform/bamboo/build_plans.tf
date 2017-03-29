resource "bamboo_build_plan" "BREAD-WAMJ" {
  key                               = "BREAD-WAMJ"
  name                              = "Artifactory Management Jobs"
  description                       = "The jobs that keep artifactory clean and lean"
  default_repository_id             = "${bamboo_repository.bamboo-configuration.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "BREAD-BREAD" {
  key                       = "BREAD-BREAD"
  name                      = "Infrastructure"
  default_repository_id     = "${bamboo_repository.infrastructure.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "BREAD-CHEF" {
  key                       = "BREAD-CHEF"
  name                      = "Chef"
  default_repository_id     = "${bamboo_repository.chef.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "BREAD-DJ" {
  key                               = "BREAD-DJ"
  name                              = "dailyjob"
  default_repository_id             = "${bamboo_repository.bread.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "BREAD-DBI" {
  key                       = "BREAD-DBI"
  name                      = "Docker Base Images"
  default_repository_id     = "${bamboo_repository.infrastructure.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "BREAD-GITCLEAN" {
  key                               = "BREAD-GITCLEAN"
  name                              = "Git Cleanup"
  default_repository_id             = "${bamboo_repository.bamboo-configuration.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "BREAD-INTAPI" {
  key                       = "BREAD-INTAPI"
  name                      = "Internal API"
  default_repository_id     = "${bamboo_repository.internal-api.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "BREAD-MESH" {
  key                       = "BREAD-MESH"
  name                      = "Mesh"
  default_repository_id     = "${bamboo_repository.mesh.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "BREAD-REPFIX" {
  key                       = "BREAD-REPFIX"
  name                      = "Repfix"
  default_repository_id     = "${bamboo_repository.repfix.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PPANTCLONE666" {
  key                               = "PDT-PPANTCLONE666"
  name                              = "AB Email Combinatorial Tests"
  default_repository_id             = "${bamboo_repository.pardot.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "PDT-BLUMSH" {
  key                       = "PDT-BLUMSH"
  name                      = "Blue Mesh"
  default_repository_id     = "${bamboo_repository.blue-mesh.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-CIM" {
  key                       = "PDT-CIM"
  name                      = "CIMTA Topology"
  default_repository_id     = "${bamboo_repository.cimta-topology.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-EHT" {
  key                       = "PDT-EHT"
  name                      = "Engagement History Topology"
  default_repository_id     = "${bamboo_repository.engagement-history-topology.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-ESF" {
  key                       = "PDT-ESF"
  name                      = "Engagement Studio Frontend"
  description               = "Frontend build for Engagement Studio"
  default_repository_id     = "${bamboo_repository.engagement-studio.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PPANTCLONE6666" {
  key                               = "PDT-PPANTCLONE6666"
  name                              = "List Email Combinatorial Tests"
  default_repository_id             = "${bamboo_repository.pardot.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "PDT-JOS" {
  key                               = "PDT-JOS"
  name                              = "Merge Master (Team Athena)"
  description                       = "Merges master branch changes into team Athenas integration branch"
  default_repository_id             = "${bamboo_repository.pardot.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "PDT-MMTP" {
  key                               = "PDT-MMTP"
  name                              = "Merge Master (Team Poseidon)"
  description                       = "Auto merges Salesforce Managed Package into Team Poseidon Integration Branch"
  default_repository_id             = "${bamboo_repository.salesforce-package.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "PDT-MDOC" {
  key                       = "PDT-MDOC"
  name                      = "Murdoc"
  description               = "Runs tests over Murdoc Rules Engine and Storm Topologies"
  default_repository_id     = "${bamboo_repository.murdoc.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PJHM" {
  key                       = "PDT-PJHM"
  name                      = "Pardot Java Hibernate Models"
  default_repository_id     = "${bamboo_repository.pardot-java-models.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDTS-SECR" {
  key                       = "PDTS-SECR"
  name                      = "Salesforce Engage Campaign Reports"
  default_repository_id     = "${bamboo_repository.engage-campaign-reports.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDTS-SEHP" {
  key                       = "PDTS-SEHP"
  name                      = "Salesforce Engagement History Package"
  default_repository_id     = "${bamboo_repository.engagement-history-package.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDTS-SMP" {
  key                       = "PDTS-SMP"
  name                      = "Salesforce Managed Package"
  default_repository_id     = "${bamboo_repository.salesforce-package.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDTS-SDODP" {
  key                       = "PDTS-SDODP"
  name                      = "SDO Demo PKG"
  description               = "BUILD the GMP or SDO Demo package"
  default_repository_id     = "${bamboo_repository.pardot-demo-org-visualforce.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "SRE-ANSBL" {
  key                       = "SRE-ANSBL"
  name                      = "Ansible"
  description               = "The man w/ the plan from Rubber City knows what to do"
  default_repository_id     = "${bamboo_repository.ansible.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "SRE-REFO" {
  key                       = "SRE-REFO"
  name                      = "Refocus"
  default_repository_id     = "${bamboo_repository.pardot-refocus.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PPANT" {
  key                       = "PDT-PPANT"
  name                      = "Pardot Parallelized PHP Tests"
  default_repository_id     = "${bamboo_repository.pardot.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PRVSVC" {
  key                       = "PDT-PRVSVC"
  name                      = "Pardot Provisioning Service"
  description               = "Build n Release for https://git.dev.pardot.com/Pardot/provisioning-service"
  default_repository_id     = "${bamboo_repository.provisioning-service.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-STORM" {
  key                       = "PDT-STORM"
  name                      = "Pardot Storm"
  description               = "Run tests for and deploy the pardot-storm project"
  default_repository_id     = "${bamboo_repository.pardot-storm.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PTHMBS" {
  key                       = "PDT-PTHMBS"
  name                      = "PiThumbs"
  default_repository_id     = "${bamboo_repository.pithumbs.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PBS" {
  key                       = "PDT-PBS"
  name                      = "Protobuf Schemas"
  default_repository_id     = "${bamboo_repository.protobuf-schemas.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-RTF" {
  key                       = "PDT-RTF"
  name                      = "Real Time Frontend"
  description               = "Robs playhouse"
  default_repository_id     = "${bamboo_repository.realtime-frontend.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-RDSMON" {
  key                       = "PDT-RDSMON"
  name                      = "redis-monitor"
  default_repository_id     = "${bamboo_repository.redis-monitor.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-RMUX" {
  key                       = "PDT-RMUX"
  name                      = "rmux"
  default_repository_id     = "${bamboo_repository.rmux.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-TSIT" {
  key                               = "PDT-TSIT"
  name                              = "Salesforce Integration Tests"
  description                       = "This runs full end to end integration tests."
  default_repository_id             = "${bamboo_repository.pardot.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "PDT-SPAT" {
  key                               = "PDT-SPAT"
  name                              = "Salesforce Package Automation Test"
  description                       = "Automation tests of the Salesforce Package"
  default_repository_id             = "${bamboo_repository.pardot.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "PDT-SDP" {
  key                       = "PDT-SDP"
  name                      = "SDO Demo Package"
  default_repository_id     = "${bamboo_repository.pardot-demo-org-visualforce.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-VAGRANT" {
  key                       = "PDT-VAGRANT"
  name                      = "vagrant-dev"
  default_repository_id     = "${bamboo_repository.vagrant-dev.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-WPMM" {
  key                               = "PDT-WPMM"
  name                              = "WebDriver - Testbed"
  default_repository_id             = "${bamboo_repository.pardot.id}"
  automatic_merging_enabled         = false
  automatic_branch_creation_enabled = false
}

resource "bamboo_build_plan" "PDT-WFST" {
  key                       = "PDT-WFST"
  name                      = "Workflow Stats"
  default_repository_id     = "${bamboo_repository.workflow-stats.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-SYM" {
  key                       = "PDT-SYM"
  name                      = "symfony"
  default_repository_id     = "${bamboo_repository.symfony.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "BREAD-BC" {
  key                       = "BREAD-BC"
  name                      = "bamboo-configuration"
  default_repository_id     = "${bamboo_repository.bamboo-configuration.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-SYMDIC" {
  key                       = "PDT-SYMDIC"
  name                      = "symfony-dic"
  default_repository_id     = "${bamboo_repository.symfony-dic.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-DC" {
  key                       = "PDT-DC"
  name                      = "Discovery-Client"
  default_repository_id     = "${bamboo_repository.Discovery-Client.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-DA" {
  key                       = "PDT-DA"
  name                      = "Discovery-Agent"
  default_repository_id     = "${bamboo_repository.Discovery-Agent.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-JSNIP" {
  key                       = "PDT-JSNIP"
  name                      = "java-snippets"
  default_repository_id     = "${bamboo_repository.java-snippets.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-AMQPLIB" {
  key                       = "PDT-AMQPLIB"
  name                      = "php-amqplib"
  default_repository_id     = "${bamboo_repository.php-amqplib.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-ASKEET" {
  key                       = "PDT-ASKEET"
  name                      = "askeet"
  default_repository_id     = "${bamboo_repository.askeet.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-MURDA" {
  key                       = "PDT-MURDA"
  name                      = "murda"
  default_repository_id     = "${bamboo_repository.murda.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-ATB" {
  key                       = "PDT-ATB"
  name                      = "all-the-bacon"
  default_repository_id     = "${bamboo_repository.all-the-bacon.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-KENDO" {
  key                       = "PDT-KENDO"
  name                      = "kendo"
  default_repository_id     = "${bamboo_repository.kendo.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-SRLP" {
  key                       = "PDT-SRLP"
  name                      = "SalesReachLicenseProvisioning"
  default_repository_id     = "${bamboo_repository.SalesReachLicenseProvisioning.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-EM" {
  key                       = "PDT-EM"
  name                      = "encryptionmanager"
  default_repository_id     = "${bamboo_repository.encryptionmanager.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-CSRF" {
  key                       = "PDT-CSRF"
  name                      = "csrf-php"
  default_repository_id     = "${bamboo_repository.csrf-php.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-GMAILC" {
  key                       = "PDT-GMAILC"
  name                      = "gmail-chrome"
  default_repository_id     = "${bamboo_repository.gmail-chrome.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-LDA" {
  key                       = "PDT-LDA"
  name                      = "lead-deck-app"
  default_repository_id     = "${bamboo_repository.lead-deck-app.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-SDEMOP" {
  key                       = "PDT-SDEMOP"
  name                      = "salesforce-demo-package"
  default_repository_id     = "${bamboo_repository.salesforce-demo-package.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-YUBILDAP" {
  key                       = "PDT-YUBILDAP"
  name                      = "yubikey-ldap"
  default_repository_id     = "${bamboo_repository.yubikey-ldap.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-BO" {
  key                       = "PDT-BO"
  name                      = "breakout"
  default_repository_id     = "${bamboo_repository.breakout.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-SFDEPL" {
  key                       = "PDT-SFDEPL"
  name                      = "SFdeploy"
  default_repository_id     = "${bamboo_repository.SFdeploy.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-AMQPLIB2" {
  key                       = "PDT-AMQPLIB2"
  name                      = "php-amqplib2"
  default_repository_id     = "${bamboo_repository.php-amqplib2.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-HOMEBREW" {
  key                       = "PDT-HOMEBREW"
  name                      = "pd-homebrew"
  default_repository_id     = "${bamboo_repository.pd-homebrew.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-STACKI" {
  key                       = "PDT-STACKI"
  name                      = "ops-stacki"
  default_repository_id     = "${bamboo_repository.ops-stacki.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-FRAMEJS" {
  key                       = "PDT-FRAMEJS"
  name                      = "frame-js"
  default_repository_id     = "${bamboo_repository.frame-js.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PARMET" {
  key                       = "PDT-PARMET"
  name                      = "ParMeter"
  default_repository_id     = "${bamboo_repository.ParMeter.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-RPMS" {
  key                       = "PDT-RPMS"
  name                      = "rpms"
  default_repository_id     = "${bamboo_repository.rpms.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-MSP" {
  key                       = "PDT-MSP"
  name                      = "mesh-sync-package"
  default_repository_id     = "${bamboo_repository.mesh-sync-package.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-KSLDS" {
  key                       = "PDT-KSLDS"
  name                      = "kendo-slds"
  default_repository_id     = "${bamboo_repository.kendo-slds.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PSTORMEX" {
  key                       = "PDT-PSTORMEX"
  name                      = "pardot-storm-example"
  default_repository_id     = "${bamboo_repository.pardot-storm-example.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PMAP" {
  key                       = "PDT-PMAP"
  name                      = "poor-mans-asset-pipeline"
  default_repository_id     = "${bamboo_repository.poor-mans-asset-pipeline.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PCSWG" {
  key                       = "PDT-PCSWG"
  name                      = "pcswg"
  default_repository_id     = "${bamboo_repository.pcswg.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-WAVE" {
  key                       = "PDT-WAVE"
  name                      = "wave"
  default_repository_id     = "${bamboo_repository.wave.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-CRUMB" {
  key                       = "PDT-CRUMB"
  name                      = "crumb"
  default_repository_id     = "${bamboo_repository.crumb.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-KT" {
  key                       = "PDT-KT"
  name                      = "kafka-tools"
  default_repository_id     = "${bamboo_repository.kafka-tools.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-AD" {
  key                       = "PDT-AD"
  name                      = "alert-dispatcher"
  default_repository_id     = "${bamboo_repository.alert-dispatcher.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-WAX" {
  key                       = "PDT-WAX"
  name                      = "wax"
  default_repository_id     = "${bamboo_repository.wax.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-SM" {
  key                       = "PDT-SM"
  name                      = "swiftmailer"
  default_repository_id     = "${bamboo_repository.swiftmailer.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-HBPHP" {
  key                       = "PDT-HBPHP"
  name                      = "pd-homebrew-php"
  default_repository_id     = "${bamboo_repository.pd-homebrew-php.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-CUMUCI" {
  key                       = "PDT-CUMUCI"
  name                      = "CumulusCI"
  default_repository_id     = "${bamboo_repository.CumulusCI.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-PESP" {
  key                       = "PDT-PESP"
  name                      = "pardot-es-parser"
  default_repository_id     = "${bamboo_repository.pardot-es-parser.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-GEOIP" {
  key                       = "PDT-GEOIP"
  name                      = "geoip-api-php"
  default_repository_id     = "${bamboo_repository.geoip-api-php.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-SSVT" {
  key                       = "PDT-SSVT"
  name                      = "StormSupervisorValidationTool"
  default_repository_id     = "${bamboo_repository.StormSupervisorValidationTool.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-SAT" {
  key                       = "PDT-SAT"
  name                      = "salesforce-actions-topologies"
  default_repository_id     = "${bamboo_repository.salesforce-actions-topologies.id}"
  automatic_merging_enabled = false
}

resource "bamboo_build_plan" "PDT-RR" {
  key                       = "PDT-RR"
  name                      = "redis-roaring"
  default_repository_id     = "${bamboo_repository.redis-roaring.id}"
  automatic_merging_enabled = false
}
