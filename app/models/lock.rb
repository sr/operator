class Lock < ActiveRecord::Base
  belongs_to :deploy_target
  belongs_to :auth_user

end