class DeployTarget < ActiveRecord::Base
  # validations, uniqueness, etc
  has_many :deploys
  belongs_to :locking_user, class_name: AuthUser

end