resource "bamboo_build_plan" "BREAD-WAMJ" {
  key                   = "BREAD-WAMJ"
  name                  = "Artifactory Management Jobs"
  description           = "The jobs that keep artifactory clean and lean"
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

resource "bamboo_build_plan" "PDT-PPANTCLONE666" {
  key                   = "PDT-PPANTCLONE666"
  name                  = "AB Email Combinatorial Tests"
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-BLUMSH" {
  key                   = "PDT-BLUMSH"
  name                  = "Blue Mesh"
  default_repository_id = "${bamboo_repository.blue-mesh.id}"
}

resource "bamboo_build_plan" "PDT-CIM" {
  key                   = "PDT-CIM"
  name                  = "CIMTA Topology"
  default_repository_id = "${bamboo_repository.cimta-topology.id}"
}

resource "bamboo_build_plan" "PDT-EHT" {
  key                   = "PDT-EHT"
  name                  = "Engagement History Topology"
  default_repository_id = "${bamboo_repository.engagement-history-topology.id}"
}

resource "bamboo_build_plan" "PDT-ESF" {
  key                   = "PDT-ESF"
  name                  = "Engagement Studio Frontend"
  description           = "Frontend build for Engagement Studio"
  default_repository_id = "${bamboo_repository.engagement-studio.id}"
}

resource "bamboo_build_plan" "PDT-PPANTCLONE6666" {
  key                   = "PDT-PPANTCLONE6666"
  name                  = "List Email Combinatorial Tests"
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-JOS" {
  key                   = "PDT-JOS"
  name                  = "Merge Master (Team Athena)"
  description           = "Merges master branch changes into team Athenas integration branch"
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-TH" {
  key                   = "PDT-TH"
  name                  = "Merge Master (Team Hephaestus)"
  description           = "Merges master branch changes into team Hephaestus integration branch"
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-MMTP" {
  key                   = "PDT-MMTP"
  name                  = "Merge Master (Team Poseidon)"
  description           = "Auto merges Salesforce Managed Package into Team Poseidon Integration Branch"
  default_repository_id = "${bamboo_repository.salesforce-package.id}"
}

resource "bamboo_build_plan" "PDT-MDOC" {
  key                   = "PDT-MDOC"
  name                  = "Murdoc"
  description           = "Runs tests over Murdoc Rules Engine and Storm Topologies"
  default_repository_id = "${bamboo_repository.murdoc.id}"
}

resource "bamboo_build_plan" "PDT-PJHM" {
  key                   = "PDT-PJHM"
  name                  = "Pardot Java Hibernate Models"
  default_repository_id = "${bamboo_repository.pardot-java-models.id}"
}

resource "bamboo_build_plan" "PDTS-SECR" {
  key                   = "PDTS-SECR"
  name                  = "Salesforce Engage Campaign Reports"
  default_repository_id = "${bamboo_repository.engage-campaign-reports.id}"
}

resource "bamboo_build_plan" "PDTS-SEHP" {
  key                   = "PDTS-SEHP"
  name                  = "Salesforce Engagement History Package"
  default_repository_id = "${bamboo_repository.engagement-history-package.id}"
}

resource "bamboo_build_plan" "PDTS-SMP" {
  key                   = "PDTS-SMP"
  name                  = "Salesforce Managed Package"
  default_repository_id = "${bamboo_repository.salesforce-package.id}"
}

resource "bamboo_build_plan" "PDTS-SDODP" {
  key                   = "PDTS-SDODP"
  name                  = "SDO Demo PKG"
  description           = "BUILD the GMP or SDO Demo package"
  default_repository_id = "${bamboo_repository.pardot-demo-org-visualforce.id}"
}

resource "bamboo_build_plan" "SRE-ANSBL" {
  key                   = "SRE-ANSBL"
  name                  = "Ansible"
  description           = "The man w/ the plan from Rubber City knows what to do"
  default_repository_id = "${bamboo_repository.ansible.id}"
}

resource "bamboo_build_plan" "SRE-REFO" {
  key                   = "SRE-REFO"
  name                  = "Refocus"
  default_repository_id = "${bamboo_repository.pardot-refocus.id}"
}

resource "bamboo_build_plan" "PDT-PPANT" {
  key                   = "PDT-PPANT"
  name                  = "Pardot Parallelized PHP Tests"
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-PRVSVC" {
  key                   = "PDT-PRVSVC"
  name                  = "Pardot Provisioning Service"
  description           = "Build n Release for https://git.dev.pardot.com/Pardot/provisioning-service"
  default_repository_id = "${bamboo_repository.provisioning-service.id}"
}

resource "bamboo_build_plan" "PDT-STORM" {
  key                   = "PDT-STORM"
  name                  = "Pardot Storm"
  description           = "Run tests for and deploy the pardot-storm project"
  default_repository_id = "${bamboo_repository.pardot-storm.id}"
}

resource "bamboo_build_plan" "PDT-PHPCS" {
  key                   = "PDT-PHPCS"
  name                  = "PHP 7 CodeSniffer"
  description           = "Run the PHP_CodeSniffer report against the commit"
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-PTHMBS" {
  key                   = "PDT-PTHMBS"
  name                  = "PiThumbs"
  default_repository_id = "${bamboo_repository.pithumbs.id}"
}

resource "bamboo_build_plan" "PDT-PBS" {
  key                   = "PDT-PBS"
  name                  = "Protobuf Schemas"
  default_repository_id = "${bamboo_repository.protobuf-schemas.id}"
}

resource "bamboo_build_plan" "PDT-RTF" {
  key                   = "PDT-RTF"
  name                  = "Real Time Frontend"
  description           = "Robs playhouse"
  default_repository_id = "${bamboo_repository.realtime-frontend.id}"
}

resource "bamboo_build_plan" "PDT-RDSMON" {
  key                   = "PDT-RDSMON"
  name                  = "redis-monitor"
  default_repository_id = "${bamboo_repository.redis-monitor.id}"
}

resource "bamboo_build_plan" "PDT-RMUX" {
  key                   = "PDT-RMUX"
  name                  = "rmux"
  default_repository_id = "${bamboo_repository.rmux.id}"
}

resource "bamboo_build_plan" "PDT-TSIT" {
  key                   = "PDT-TSIT"
  name                  = "Salesforce Integration Tests"
  description           = "This runs full end to end integration tests."
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-SPAT" {
  key                   = "PDT-SPAT"
  name                  = "Salesforce Package Automation Test"
  description           = "Automation tests of the Salesforce Package"
  default_repository_id = "${bamboo_repository.salesforce-package.id}"
}

resource "bamboo_build_plan" "PDT-SDP" {
  key                   = "PDT-SDP"
  name                  = "SDO Demo Package"
  default_repository_id = "${bamboo_repository.pardot-demo-org-visualforce.id}"
}

resource "bamboo_build_plan" "PDT-VAGRANT" {
  key                   = "PDT-VAGRANT"
  name                  = "vagrant-dev"
  default_repository_id = "${bamboo_repository.vagrant-dev.id}"
}

resource "bamboo_build_plan" "PDT-WT" {
  key                   = "PDT-WT"
  name                  = "Webdriver - Full Suite"
  description           = "This plan runs the Pardot, Engagement Studio, and Salesforce webdriver tests on every push to the ParDriver repo"
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-WPM" {
  key                   = "PDT-WPM"
  name                  = "Webdriver - Grid"
  description           = "Runs critical tests against Chrome in a local grid"
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-WPMM" {
  key                   = "PDT-WPMM"
  name                  = "WebDriver - Testbed"
  default_repository_id = "${bamboo_repository.pardot.id}"
}

resource "bamboo_build_plan" "PDT-WES" {
  key                   = "PDT-WES"
  name                  = "Webdriver Engagement Studio"
  default_repository_id = "${bamboo_repository.engagement-studio.id}"
}

resource "bamboo_build_plan" "PDT-WFST" {
  key                   = "PDT-WFST"
  name                  = "Workflow Stats"
  default_repository_id = "${bamboo_repository.workflow-stats.id}"
}
