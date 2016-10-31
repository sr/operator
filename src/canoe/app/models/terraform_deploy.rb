class TerraformDeploy < ActiveRecord::Base
  belongs_to :auth_user
  belongs_to :terraform_project

  def self.pending
    where(completed_at: nil).order("id DESC")
  end

  def project_name
    terraform_project.name
  end

  def user_name
    auth_user.name.presence || auth_user.email
  end
end
