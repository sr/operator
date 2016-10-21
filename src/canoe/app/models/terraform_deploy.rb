class TerraformDeploy < ActiveRecord::Base
  belongs_to :auth_user
  belongs_to :project

  def self.pending(estate)
    where("estate_name = ? AND completed_at IS NULL", estate).order("id DESC")
  end

  def user_name
    auth_user.name
  end
end
