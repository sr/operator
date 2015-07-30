Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :developer
  else
    provider :google_oauth2,
      ENV.fetch("GOOGLE_CLIENT_ID"),
      ENV.fetch("GOOGLE_SECRET"),
      name: "google",
      access_type: "online"
  end
end
