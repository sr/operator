class GithubInstallation < ApplicationRecord
  has_many :repositories, class_name: "GithubRepository"
  has_many :team_memberships, class_name: "GithubTeamMembership", dependent: :destroy

  def self.current
    find_by!(hostname: Changeling.config.github_hostname)
  end

  def team_slugs
    team_memberships.select(:team_slug).distinct.map(&:team_slug)
  end

  def team_members(team_slugs)
    team_memberships
      .where(team_slug: team_slugs)
      .pluck(:user_login)
      .map { |login| GithubUser.new(login) }
  end

  def synchronize
    github_client.organizations.each do |organization|
      synchronize_organization_repositories(organization.login)
      synchronize_organization_teams(organization.login)
    end
  end

  def github_client
    @github_client ||= Clients::GitHub.new(github_token)
  end

  private

  def synchronize_organization_repositories(organization_name)
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

  def synchronize_organization_teams(organization_name)
    memberships = []

    github_client.organization_teams(organization_name).each do |org_team|
      github_client.team_members(org_team.id).each do |user|
        memberships << GithubTeamMembership.new(
          github_installation_id: id,
          github_team_id: org_team.id,
          github_user_id: user.id,
          team_slug: "#{organization_name}/#{org_team.slug}",
          user_login: user.login
        )
      end
    end

    ActiveRecord::Base.transaction do
      team_memberships.delete_all
      memberships.map(&:save!)
    end
  end

  def github_token
    Changeling.config.github_service_account_token
  end
end
