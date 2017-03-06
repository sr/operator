class Lock < ApplicationRecord
  belongs_to :deploy_target
  belongs_to :auth_user
  belongs_to :project
end
