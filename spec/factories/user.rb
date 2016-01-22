FactoryGirl.define do
  factory :auth_user, aliases: [:user] do
    sequence(:email) { |n| "alindeman+fake#{n}@salesforce.com" }
    name "John Doe"
    sequence(:uid) { |n| n.to_s }
    token "token"
  end
end
