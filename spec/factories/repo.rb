FactoryGirl.define do
  factory :repo do
    sequence(:name) { |n| "pardot#{n}" }
    icon "cloud"
    supports_branch_deploy true
  end
end
