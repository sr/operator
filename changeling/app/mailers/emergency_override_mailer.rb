# Generate Emergency override email notifications
class EmergencyOverrideMailer < ApplicationMailer
  def send_multipass(multipass)
    @multipass = multipass
    mail(to: "tools+hipaa+notifications@heroku.com",
         subject: "Changeling Emergency Override #{multipass.repository_name}")
  end
end
