class ChangelingConfig
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
    if pardot?
      ENV.fetch("CHANGELING_GHOST_LOGIN")
    else
      "changeling-production"
    end
  end

  def ghost_user_token
    if pardot?
      ENV.fetch("GITHUB_COMMIT_STATUS_TOKEN")
    else
      ENV["GITHUB_COMMIT_STATUS_TOKEN"]
    end
  end

  def github_hostname
    if pardot?
      ENV.fetch("GITHUB_HOSTNAME")
    else
      "github.com"
    end
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
end
