FactoryGirl.define do
  factory :server do
    sequence(:hostname) { |n| "app-s#{n}.example" }
  end
end
