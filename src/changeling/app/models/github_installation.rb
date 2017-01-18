class GithubInstallation < ApplicationRecord
  has_many :repositories, class_name: "GithubRepository"

  def self.current
    find_by!(hostname: Changeling.config.github_hostname)
  end

  def synchronize
    github_client.organizations.each do |organization|
      synchronize_organization(organization.login)
    end
  end

  def github_client
    @github_client ||= Clients::GitHub.new(github_token)
  end

  private

  def synchronize_organization(organization_name)
    repo_ids = Set.new([])

    github_client.organization_repositories(organization_name).each do |org_repo|
      repo_ids.add(org_repo.id)

      repo = repositories.find_or_initialize_by(
        github_id: org_repo.id,
        github_owner_id: org_repo.owner.id,
      )
      repo.update!(owner: org_repo.owner.login, name: org_repo.name)
    end

    repositories.where.not(github_id: repo_ids.to_a).each do |repo|
      repo.update!(deleted_at: Time.current)
    end
  end

  def github_token
    Changeling.config.github_service_account_token
  end
end
