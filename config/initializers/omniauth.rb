Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development? || Rails.env.test?
    provider :developer
  else
    provider :google_oauth2,
      ENV["GOOGLE_CLIENT_ID"],
      ENV["GOOGLE_SECRET"],
      name: "google",
      access_type: "online"
  end

  case Rails.env
  when "production"
    OmniAuth.config.full_host = "https://canoe.pardot.com"
  when "app.dev"
    OmniAuth.config.full_host = "http://canoe.dev.pardot.com"
  end
end
