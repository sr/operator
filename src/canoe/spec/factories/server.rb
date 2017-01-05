FactoryGirl.define do
  factory :server do
    sequence(:hostname) { |n| "pardot2-app-1-#{n}-ue1" }
  end
end
