FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "pardot#{n}" }
    repository { "Pardot/#{name}" }
    icon "cloud"
  end
end
