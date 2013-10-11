class Deploy < ActiveRecord::Base
  # validations, uniqueness, etc
  # validate type = %w[tag branch commit]
  belongs_to :deploy_target
  belongs_to :auth_user

  # TODO: log location, etd
end