Rails.application.config.middleware.use OmniAuth::Builder do
  case Rails.env
  when "production"
    OmniAuth.config.full_host = "https://canoe.pardot.com"
  when "app.dev"
    OmniAuth.config.full_host = "http://canoe.dev.pardot.com"
  end

  if Rails.env.development? || Rails.env.test?
    provider :developer
  else
    provider :ldap,
      title: "Pardot LDAP",
      host: ENV["LDAP_HOST"],
      port: ENV.fetch("LDAP_PORT", 389),
      method: :tls,
      filter: "(&(objectClass=person)(ou:dn:=People))",
      base: ENV["LDAP_BASE"],
      uid: "uid"
  end
end
