namespace :canoe do
  desc 'Create repos for deployment'
  task :create_repos => :environment do
    Repo.find_or_initialize_by(name: 'pardot').tap { |repo|
      repo.icon = 'cloud'
      repo.supports_branch_deploy = true
      repo.deploys_via_artifacts = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'PPANT'
    }.save

    Repo.find_or_initialize_by(name: 'pithumbs').tap { |repo|
      repo.icon = 'thumbs-up'
      repo.supports_branch_deploy = true
      repo.deploys_via_artifacts = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'PTHMBS'
    }.save

    Repo.find_or_initialize_by(name: 'realtime-frontend').tap { |repo|
      repo.icon = 'bullhorn'
      repo.supports_branch_deploy = false
      repo.deploys_via_artifacts = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'RTF'
    }.save

    Repo.find_or_initialize_by(name: 'workflow-stats').tap { |repo|
      repo.icon = 'fighter-jet'
      repo.deploys_via_artifacts = true
      repo.supports_branch_deploy = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'WFST'
    }.save

    Repo.find_or_initialize_by(name: 'murdoc').tap { |repo|
      repo.icon = 'bolt'
      repo.deploys_via_artifacts = true
      repo.supports_branch_deploy = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'MDOC'
    }.save

    if Rails.env.production? || Rails.env.development? || Rails.env.test?
      Repo.find_or_initialize_by(name: 'blue-mesh').tap { |repo|
        repo.icon = 'th'
        repo.deploys_via_artifacts = true
        repo.supports_branch_deploy = true
        repo.bamboo_project = 'PDT'
        repo.bamboo_plan = 'BLUMSH'
      }.save
    end
  end

  desc 'Create targets for deployment'
  task :create_targets => :environment do
    case Rails.env
    when 'development'
      DeployTarget.find_or_initialize_by(name: 'dev').save
      DeployTarget.find_or_initialize_by(name: 'test').save
    when 'test'
      # tests create their own targets via FactoryGirl
    when 'app.dev'
      DeployTarget.find_or_initialize_by(name: 'staging').save
      DeployTarget.find_or_initialize_by(name: 'engagement').tap { |target|
        target.enabled = false
      }.save
    when 'production'
      DeployTarget.find_or_initialize_by(name: "production").save
      DeployTarget.find_or_initialize_by(name: "production_dfw").save
    end
  end
end
