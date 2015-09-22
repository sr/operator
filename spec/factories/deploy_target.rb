FactoryGirl.define do
  factory :deploy_target do
    name "test"
    script_path "#{Rails.root}/../sync_scripts"
    lockable false
    locked false
  end
end
