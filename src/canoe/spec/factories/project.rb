FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "pardot#{n}" }
    repository { "Pardot/#{name}" }
    icon "cloud"
    compliant_builds_required true
    default_branch "master"
  end
end
