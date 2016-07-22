FactoryGirl.define do
  factory :deploy_scenario do
    association :project, factory: :project
    association :server, factory: :server
    association :deploy_target, factory: :deploy_target
  end
end
