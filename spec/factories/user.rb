FactoryGirl.define do
  factory :auth_user, aliases: [:user] do
    email "alindeman@salesforce.com"
    name "John Doe"
    uid "123456789"
    token "token"
  end
end
