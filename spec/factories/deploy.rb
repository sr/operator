FactoryGirl.define do
  factory :deploy do
    what "branch"
    what_details "master"
    completed true

    association :auth_user, factory: :user
  end
end
