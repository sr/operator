resource "github_repository" "gmail-firefox" {
  name          = "gmail-firefox"
  description   = "Adds a \"Send with Pardot\" button to GMail / Google Apps"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "gmail-firefox_developers" {
  repository = "${github_repository.gmail-firefox.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "gmail-firefox_service-accounts-read-only" {
  repository = "${github_repository.gmail-firefox.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "supportbot" {
  name          = "supportbot"
  description   = "A supporting, positive and self-starting robit"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "supportbot_developers" {
  repository = "${github_repository.supportbot.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "supportbot_service-accounts-read-only" {
  repository = "${github_repository.supportbot.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "pardot-for-applemail" {
  name          = "pardot-for-applemail"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-for-applemail_developers" {
  repository = "${github_repository.pardot-for-applemail.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-for-applemail_service-accounts-read-only" {
  repository = "${github_repository.pardot-for-applemail.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "vagrant-dev" {
  name          = "vagrant-dev"
  description   = "Pardot's Vagrant setup"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "vagrant-dev_developers" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "vagrant-dev_ops" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "vagrant-dev_service-accounts-read-only" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "vagrant-dev_tier-2-support" {
  repository = "${github_repository.vagrant-dev.name}"
  team_id    = "${github_team.tier-2-support.id}"
  permission = "push"
}

resource "github_repository" "pardot-child" {
  name          = "pardot-child"
  description   = "The new www.pardot.com wordpress theme!"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-child_service-accounts-read-only" {
  repository = "${github_repository.pardot-child.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "tracker-tracker" {
  name          = "tracker-tracker"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "tracker-tracker_developers" {
  repository = "${github_repository.tracker-tracker.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "tracker-tracker_service-accounts-read-only" {
  repository = "${github_repository.tracker-tracker.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "internal-api" {
  name          = "internal-api"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "internal-api_developers" {
  repository = "${github_repository.internal-api.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "internal-api_service-accounts-read-only" {
  repository = "${github_repository.internal-api.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "internal-api_ops" {
  repository = "${github_repository.internal-api.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "internal-api_service-accounts-write-only" {
  repository = "${github_repository.internal-api.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_repository" "parbot" {
  name          = "parbot"
  description   = "This repository has been moved to https://git.dev.pardot.com/Pardot/bread"
  homepage_url  = ""
  private       = true
  has_issues    = false
  has_downloads = true
  has_wiki      = false
}

resource "github_team_repository" "parbot_service-accounts-read-only" {
  repository = "${github_repository.parbot.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "parbot_ops" {
  repository = "${github_repository.parbot.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_repository" "realtime-frontend" {
  name          = "realtime-frontend"
  description   = "Realtime frontend server"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "realtime-frontend_developers" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "realtime-frontend_service-accounts-write-only" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "realtime-frontend_service-accounts-read-only" {
  repository = "${github_repository.realtime-frontend.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "leaddeck-container" {
  name          = "leaddeck-container"
  description   = "Container App for LeadDeck"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "leaddeck-container_developers" {
  repository = "${github_repository.leaddeck-container.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "leaddeck-container_service-accounts-read-only" {
  repository = "${github_repository.leaddeck-container.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "devops-cap" {
  name          = "devops-cap"
  description   = "A Capistrano Repo of Useful Tasks"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "devops-cap_developers" {
  repository = "${github_repository.devops-cap.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "devops-cap_service-accounts-read-only" {
  repository = "${github_repository.devops-cap.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "thunderbird-plugin" {
  name          = "thunderbird-plugin"
  description   = "Thunderbird Plugin for Pardot"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "thunderbird-plugin_developers" {
  repository = "${github_repository.thunderbird-plugin.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "thunderbird-plugin_service-accounts-read-only" {
  repository = "${github_repository.thunderbird-plugin.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "frontend-tests" {
  name          = "frontend-tests"
  description   = "A front-end test suite for the Pardot application"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "frontend-tests_developers" {
  repository = "${github_repository.frontend-tests.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "frontend-tests_service-accounts-read-only" {
  repository = "${github_repository.frontend-tests.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "symfony" {
  name          = "symfony"
  description   = "Pardot fork of symfony"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "symfony_service-accounts-read-only" {
  repository = "${github_repository.symfony.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "bamboo-elastic-instance" {
  name          = "bamboo-elastic-instance"
  description   = "Configuration scripts for Pardot bamboo continuous integration agents"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "bamboo-elastic-instance_developers" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "bamboo-elastic-instance_service-accounts-write-only" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "bamboo-elastic-instance_service-accounts-read-only" {
  repository = "${github_repository.bamboo-elastic-instance.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "symfony-dic" {
  name          = "symfony-dic"
  description   = "Symfony Dependency Injection"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "symfony-dic_developers" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "symfony-dic_service-accounts-read-only" {
  repository = "${github_repository.symfony-dic.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "pardot-maven-artifacts" {
  name          = "pardot-maven-artifacts"
  description   = "Maven Artifacts for Pardot Java projects"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "pardot-maven-artifacts_developers" {
  repository = "${github_repository.pardot-maven-artifacts.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "pardot-maven-artifacts_service-accounts-read-only" {
  repository = "${github_repository.pardot-maven-artifacts.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "java-services" {
  name          = "java-services"
  description   = "An api layer for Visitor information"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "java-services_developers" {
  repository = "${github_repository.java-services.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "java-services_service-accounts-write-only" {
  repository = "${github_repository.java-services.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_team_repository" "java-services_service-accounts-read-only" {
  repository = "${github_repository.java-services.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "java-services_ops" {
  repository = "${github_repository.java-services.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_repository" "Discovery-Client" {
  name          = "Discovery-Client"
  description   = "Discovery Service Client to be run on localhost of every pardot server"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "Discovery-Client_developers" {
  repository = "${github_repository.Discovery-Client.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "Discovery-Client_service-accounts-read-only" {
  repository = "${github_repository.Discovery-Client.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "statusboard" {
  name          = "statusboard"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "statusboard_service-accounts-read-only" {
  repository = "${github_repository.statusboard.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "Discovery-Agent" {
  name          = "Discovery-Agent"
  description   = "Agent for checking health of pardot services and publishing results to the Discovery Service"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "Discovery-Agent_developers" {
  repository = "${github_repository.Discovery-Agent.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "Discovery-Agent_service-accounts-read-only" {
  repository = "${github_repository.Discovery-Agent.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "premail_api" {
  name          = "premail_api"
  description   = "API that wraps the premail gem"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "premail_api_service-accounts-read-only" {
  repository = "${github_repository.premail_api.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "elastic-etl" {
  name          = "elastic-etl"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "elastic-etl_developers" {
  repository = "${github_repository.elastic-etl.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "elastic-etl_service-accounts-read-only" {
  repository = "${github_repository.elastic-etl.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "docs" {
  name          = "docs"
  description   = "The Documentations"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "docs_developers" {
  repository = "${github_repository.docs.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "docs_ops" {
  repository = "${github_repository.docs.name}"
  team_id    = "${github_team.ops.id}"
  permission = "push"
}

resource "github_team_repository" "docs_service-accounts-read-only" {
  repository = "${github_repository.docs.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "parbot-rover" {
  name          = "parbot-rover"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "parbot-rover_developers" {
  repository = "${github_repository.parbot-rover.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "parbot-rover_service-accounts-read-only" {
  repository = "${github_repository.parbot-rover.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "repfix" {
  name          = "repfix"
  description   = "Replication fixer scripts"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "repfix_service-accounts-read-only" {
  repository = "${github_repository.repfix.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_team_repository" "repfix_service-accounts-write-only" {
  repository = "${github_repository.repfix.name}"
  team_id    = "${github_team.service-accounts-write-only.id}"
  permission = "push"
}

resource "github_repository" "node_modules" {
  name          = "node_modules"
  description   = "Node module dependencies for Pardot"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "node_modules_developers" {
  repository = "${github_repository.node_modules.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "node_modules_service-accounts-read-only" {
  repository = "${github_repository.node_modules.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "java-services-tools" {
  name          = "java-services-tools"
  description   = "A set of shell scripts that make managing pardot java services machines less painful."
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "java-services-tools_developers" {
  repository = "${github_repository.java-services-tools.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "java-services-tools_service-accounts-read-only" {
  repository = "${github_repository.java-services-tools.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "java-snippets" {
  name          = "java-snippets"
  description   = ""
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "java-snippets_developers" {
  repository = "${github_repository.java-snippets.name}"
  team_id    = "${github_team.developers.id}"
  permission = "push"
}

resource "github_team_repository" "java-snippets_service-accounts-read-only" {
  repository = "${github_repository.java-snippets.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}

resource "github_repository" "supportbot-zendesk" {
  name          = "supportbot-zendesk"
  description   = "SupportBot Zendesk App"
  homepage_url  = ""
  private       = true
  has_issues    = true
  has_downloads = true
  has_wiki      = true
}

resource "github_team_repository" "supportbot-zendesk_service-accounts-read-only" {
  repository = "${github_repository.supportbot-zendesk.name}"
  team_id    = "${github_team.service-accounts-read-only.id}"
  permission = "pull"
}
