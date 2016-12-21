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

  def email_notifications_enabled?
    return @email_notifications_enabled if defined?(@email_notifications_enabled)
    @email_notifications_enabled = heroku?
  end
  attr_writer :email_notifications_enabled

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

  def pardot_rollout_phase1_enabled?
    !ENV["PARDOT_ROLLOUT_PHASE1_ENABLED"].to_s.empty?
  end

  def compliance_status_context
    if pardot?
      ENV.fetch("CHANGELING_COMPLIANCE_STATUS_CONTEXT")
    else
      "heroku/compliance"
    end
  end

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

  def jira_client
    return @jira_client if defined?(@jira_client)
    options = {
      username: ENV.fetch("JIRA_USERNAME"),
      password: ENV.fetch("JIRA_PASSWORD"),
      site: jira_url,
      auth_type: :basic,
      rest_base_path: "/rest/api/2",
      context_path: ""
    }
    @jira_client = JIRA::Client.new(options)
  end
end
