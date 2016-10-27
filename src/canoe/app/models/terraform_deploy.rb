class TerraformDeploy < ActiveRecord::Base
  belongs_to :auth_user
  belongs_to :project

  def self.pending(estate)
    where("estate_name = ? AND completed_at IS NULL", estate).order("id DESC")
  end

  def user_name
    name = auth_user.name

    if name.empty?
      return auth_user.email
    end

    name
  end
end
