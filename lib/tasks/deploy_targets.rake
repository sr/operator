namespace :canoe do
  desc 'Create repos for deployment'
  task :create_repos => :environment do
    next if Rails.env.test?

    Repo.find_or_initialize_by(name: 'pardot').tap { |repo|
      repo.icon = 'cloud'
      repo.supports_branch_deploy = true
      repo.deploys_via_artifacts = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'PPANT'
    }.save!

    Repo.find_or_initialize_by(name: 'pithumbs').tap { |repo|
      repo.icon = 'thumbs-up'
      repo.supports_branch_deploy = true
      repo.deploys_via_artifacts = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'PTHMBS'
    }.save!

    Repo.find_or_initialize_by(name: 'realtime-frontend').tap { |repo|
      repo.icon = 'bullhorn'
      repo.supports_branch_deploy = false
      repo.deploys_via_artifacts = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'RTF'
    }.save!

    Repo.find_or_initialize_by(name: 'workflow-stats').tap { |repo|
      repo.icon = 'fighter-jet'
      repo.deploys_via_artifacts = true
      repo.supports_branch_deploy = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'WFST'
    }.save!

    Repo.find_or_initialize_by(name: 'murdoc').tap { |repo|
      repo.icon = 'bolt'
      repo.deploys_via_artifacts = true
      repo.supports_branch_deploy = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'MDOC'
    }.save!

    if Rails.env.production? || Rails.env.development? || Rails.env.test?
      Repo.find_or_initialize_by(name: 'blue-mesh').tap { |repo|
        repo.icon = 'th'
        repo.deploys_via_artifacts = true
        repo.supports_branch_deploy = true
        repo.bamboo_project = 'PDT'
        repo.bamboo_plan = 'BLUMSH'
      }.save!
    end
  end

  desc 'Create targets for deployment'
  task :create_targets => :environment do
    next if Rails.env.test?

    case Rails.env
    when 'development'
      DeployTarget.find_or_initialize_by(name: 'dev').save!
      DeployTarget.find_or_initialize_by(name: 'test').save!
    when 'production'
      DeployTarget.find_or_initialize_by(name: 'staging').save!
      DeployTarget.find_or_initialize_by(name: "production").save!
      DeployTarget.find_or_initialize_by(name: "production_dfw").save!
    end
  end

  desc 'Create deploy ACLs'
  task :create_deploy_acls => :environment do
    next if Rails.env.test?

    case Rails.env
    when 'production'
      # Until we coordinate with the Security team to make more granular groups,
      # require 'releasebox' for all production deployments in all repos
      production_targets = DeployTarget.where(name: ["production", "production_dfw"])
      Repo.find_each do |repo|
        production_targets.each do |target|
          DeployACLEntry.find_or_initialize_by(repo_id: repo.id, deploy_target_id: target.id).tap { |entry|
            entry.acl_type = "ldap_group"
            entry.value = ["releasebox"]
          }.save!
        end
      end
    end
  end
end
