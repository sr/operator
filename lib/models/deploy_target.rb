class DeployTarget < ActiveRecord::Base
  # validations, uniqueness, etc
  has_many :deploys
  belongs_to :locking_user, class_name: AuthUser

  def active_deploy
    # see if the most recent deploy is not completed
    @_active_deploy ||= most_recent_deploy.try(:completed) ? nil : most_recent_deploy
  end

  def most_recent_deploy
    @_most_recent_deploy ||= self.deploys.order(:created_at).first
  end

end