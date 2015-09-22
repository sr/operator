class Lock < ActiveRecord::Base
  belongs_to :deploy_target
  belongs_to :auth_user
  belongs_to :repo
end
