FactoryGirl.define do
  factory :deploy_notification do
    hipchat_room_id 1
    association :project, factory: :project
  end
end
