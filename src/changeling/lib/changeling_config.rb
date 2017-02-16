# Class for enabling feature flags for pardot or heroku's installation
class ChangelingConfig
  def heroku?
    !pardot?
  end

  def pardot?
    return @pardot if defined?(@pardot)
    @pardot = !ENV["PARDOT"].to_s.empty?
  end
  attr_writer :pardot

  def require_heroku_organization_membership?
    return @require_heroku_organization_membership if defined?(@require_heroku_organization_membership)
    @require_heroku_organization_membership = !pardot?
  end
  attr_writer :require_heroku_organization_membership

  def default_required_testing_statuses
    return [PardotRepository::TEST_STATUS]
  end

  def email_notifications_enabled?
    return @email_notifications_enabled if defined?(@email_notifications_enabled)
    @email_notifications_enabled = heroku?
  end
  attr_writer :email_notifications_enabled

  def owners_files_enabled?
    pardot?
  end

  def compliance_comment_enabled_repositories
    return @compliance_comment_enabled_repositories if defined?(@compliance_comment_enabled_repositories)
    @compliance_comment_enabled_repositories = Array(ENV["CHANGELING_COMPLIANCE_COMMENT_ENABLED_REPOSITORIES"].split(","))
  end
  attr_writer :compliance_comment_enabled_repositories

  def emergency_merge_ticket_enabled_repositories
    return @emergency_merge_ticket_enabled_repositories if defined?(@emergency_merge_ticket_enabled_repositories)
    @emergency_merge_ticket_enabled_repositories = Array(ENV["CHANGELING_EMERGENCY_MERGE_TICKET_ENABLED_REPOSITORIES"].split(","))
  end
  attr_writer :emergency_merge_ticket_enabled_repositories

  def page_title
    if pardot?
      "Pardot Compliance"
    else
      "Changeling"
    end
  end

  def jira_url
    if pardot?
      ENV.fetch("CHANGELING_JIRA_URL", "https://jira.dev.pardot.com")
    else
      ""
    end
  end

  def gus_url
    "https://gus.my.salesforce.com"
  end

  def review_approval_enabled_for?(user)
    if pardot?
      return true
    else
      %w{atmos jroes stellacotton ys}.include?(user.github_login)
    end
  end

  def approval_via_comment_enabled?
    return @approval_via_comment_enabled if defined?(@approval_via_comment_enabled)
    @approval_via_comment_enabled = !pardot?
  end
  attr_writer :approval_via_comment_enabled

  def compliance_status_context
    if pardot?
      ENV.fetch("CHANGELING_COMPLIANCE_STATUS_CONTEXT")
    else
      "heroku/compliance"
    end
  end

  def sre_team_slug
    return @sre_team_slug if defined?(@sre_team_slug)

    @sre_team_slug = \
      ENV.fetch("CHANGELING_SRE_TEAM_SLUG", "Pardot/site-reliability-engineers")
  end
  attr_writer :sre_team_slug

  def default_repo_name
    if pardot?
      "Pardot/unknown"
    else
      "heroku/unknown-app"
    end
  end

  def rollbar_enabled?
    if pardot?
      false
    else
      !Rails.env.test?
    end
  end

  def ghost_user_login
    "changeling-production"
  end

  def ghost_user_token
    ENV["GITHUB_COMMIT_STATUS_TOKEN"]
  end

  def github_hostname
    if pardot?
      ENV.fetch("GITHUB_HOSTNAME", "git.dev.pardot.com")
    else
      "github.com"
    end
  end

  def github_url
    @github_url ||= URI("https://#{github_hostname}")
  end

  def github_service_account_username
    if pardot?
      ENV.fetch("GITHUB_USERNAME")
    else
      ENV["GITHUB_USERNAME"]
    end
  end

  def github_service_account_password
    if pardot?
      ENV.fetch("GITHUB_PASSWORD")
    else
      ENV["GITHUB_PASSWORD"]
    end
  end

  def github_service_account_token
    ENV.fetch("GITHUB_TOKEN")
  end

  def github_source_ips
    Array(ENV.fetch("GITHUB_WEBHOOK_SOURCE_IP", "192.30.252.0/22"))
  end

  def github_api_endpoint
    if pardot?
      "https://#{github_hostname}/api/v3"
    else
      "https://api.github.com"
    end
  end

  def github_oauth_id
    # Preserve current Heroku behavior of silently ignoring missing config keys
    if pardot?
      ENV.fetch("GITHUB_OAUTH_ID")
    else
      ENV["GITHUB_OAUTH_ID"]
    end
  end

  def github_oauth_secret
    if pardot?
      ENV.fetch("GITHUB_OAUTH_SECRET")
    else
      ENV["GITHUB_OAUTH_SECRET"]
    end
  end

  def emergency_ticket_jira_project_key
    ENV.fetch("CHANGELING_EMERGENCY_TICKET_JIRA_PROJECT_KEY", "BREAD")
  end

  def jira_username
    ENV.fetch("JIRA_USERNAME")
  end

  def jira_password
    ENV.fetch("JIRA_PASSWORD")
  end

  def jira_client
    return @jira_client if defined?(@jira_client)
    options = {
      username: jira_username,
      password: jira_password,
      site: jira_url,
      auth_type: :basic,
      rest_base_path: "/rest/api/2",
      context_path: ""
    }
    @jira_client = JIRA::Client.new(options)
  end
end
