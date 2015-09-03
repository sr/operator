FactoryGirl.define do
  factory :auth_user, aliases: [:user] do
    sequence(:email) { |n| "alindeman+fake#{n}@salesforce.com" }
    name "John Doe"
    uid "123456789"
    token "token"
  end
end
