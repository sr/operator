OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    OmniAuth.config.full_host = "https://canoe.dev.pardot.com"
  end

  if Rails.env.development? || Rails.env.test?
    provider :developer
  else
    provider :ldap,
      title: "Pardot LDAP",
      host: ENV["LDAP_HOST"],
      port: ENV.fetch("LDAP_PORT", 389),
      method: :tls,
      filter: "(&(uid=%{username})(objectClass=person)(ou:dn:=People))",
      base: ENV["LDAP_BASE"],
      uid: "uid"

    # Workaround for https://github.com/intridea/omniauth-ldap/pull/45
    config = OmniAuth::Strategies::LDAP.class_variable_get(:@@config)
    if config && config["email"]
      # Prefer `email` attribute over `mail` attribute to support users who have
      # multiple email address, but one primary email address
      config["email"] = %w[email mail userPrincipalName]
    end
  end
end
