FactoryGirl.define do
  factory :auth_user, aliases: [:user] do
    sequence(:email) { |n| "alindeman+fake#{n}@salesforce.com" }
    name "John Doe"
    sequence(:uid, &:to_s)
    token "token"
  end
end
