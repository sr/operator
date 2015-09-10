FactoryGirl.define do
  factory :deploy do
    what "branch"
    what_details "master"
    sha "abc123"
    completed true

    association :auth_user, factory: :user
  end
end
