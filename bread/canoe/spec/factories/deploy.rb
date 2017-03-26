FactoryGirl.define do
  factory :deploy do
    branch "master"
    sha "abc123"
    completed true
    project_name "pardot"

    association :auth_user, factory: :user
    association :deploy_target, factory: :deploy_target
  end
end
