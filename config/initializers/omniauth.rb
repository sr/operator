Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.development?
    provider :developer
  else
    provider :google_oauth2,
      ENV["GOOGLE_CLIENT_ID"],
      ENV["GOOGLE_SECRET"],
      name: "google",
      access_type: "online"
  end
end
