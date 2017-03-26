# Top-level class for all outgoing email
class ApplicationMailer < ActionMailer::Base
  default from: "tools+noreply@heroku.com"

  layout "mailer"
end
