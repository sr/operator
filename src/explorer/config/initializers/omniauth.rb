Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    OmniAuth.config.full_host = "https://explorer.dev.pardot.com"
  end

  if Rails.env.development? || Rails.env.test?
    provider :developer
  else
    provider :ldap,
      title: "Pardot LDAP",
      host: ENV.fetch("LDAP_HOST"),
      port: ENV.fetch("LDAP_PORT", 389),
      method: :tls,
      filter: "(&(uid=%{username})(objectClass=person)(ou:dn:=People))",
      base: ENV.fetch("LDAP_BASE"),
      uid: "uid"
  end
end
