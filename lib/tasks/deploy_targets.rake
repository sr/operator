namespace :canoe do
  desc 'Create repos for deployment'
  task :create_repos => :environment do
    Repo.find_or_initialize_by(name: 'pardot').tap { |repo|
      repo.icon = 'cloud'
      repo.supports_branch_deploy = true
      # TODO: Is being toggled manually in app.dev; not quite ready for
      # production rollout yet
      # repo.deploys_via_artifacts = true
      repo.bamboo_project = 'PDT'
      repo.bamboo_plan = 'PPANT'
    }.save

    Repo.find_or_initialize_by(name: 'pithumbs').tap { |repo|
      repo.icon = 'thumbs-up'
      repo.supports_branch_deploy = true
    }.save

    Repo.find_or_initialize_by(name: 'realtime-frontend').tap { |repo|
      repo.icon = 'bullhorn'
      repo.supports_branch_deploy = false
    }.save

    Repo.find_or_initialize_by(name: 'workflow-stats').tap { |repo|
      repo.icon = 'fighter-jet'
      repo.deploys_via_artifacts = true
      repo.supports_branch_deploy = true
      repo.bamboo_project = 'WFST'
      repo.bamboo_plan = 'WFS'
    }.save
  end

  desc 'Create deploy targets for dev env'
  task :create_dev_targets => :environment do
    dev = DeployTarget.where(name: 'dev').first
    DeployTarget.create(
      name: 'dev',
      script_path: "#{Rails.root}/../sync_scripts",
      locked: false,
    ) if !dev

    test = DeployTarget.where(name: 'test').first
    DeployTarget.create(
      name: 'test',
      script_path: "#{Rails.root}/../sync_scripts",
      locked: true,
    ) if !test
  end

  desc 'Create deploy targets for test/staging envs'
  task :create_staging_targets => :environment do
    testing_env = DeployTarget.where(name: 'test').first
    DeployTarget.create(
      name: 'test',
      script_path: '/opt/sync/test',
      locked: false,
    ) if !testing_env

    staging_env = DeployTarget.where(name: 'staging').first
    DeployTarget.create(
      name: 'staging',
      script_path: '/opt/sync/staging',
      locked: false,
    ) if !staging_env
  end

  desc 'Create deploy targets for new-staging env'
  task :create_new_staging_targets => :environment do
    staging_env = DeployTarget.where(name: 'staging').first
    DeployTarget.create(
      name: 'staging',
      script_path: '/opt/sync/staging',
      locked: false,
    ) if !staging_env

    engage_env = DeployTarget.where(name: 'engagement').first
    DeployTarget.create(
      name: 'engagement',
      script_path: '/opt/sync/staging',
      locked: false,
    ) if !engage_env
  end

  desc "Create deploy target for production env"
  task :create_prod_targets => :environment do
    prod_env = DeployTarget.where(name: "production").first
    DeployTarget.create(
      name: "production",
      script_path: "/opt/sync/production",
      locked: false,
    ) unless prod_env
  end

  # added for ease of chef'ing
  task :create_development_targets => :environment do
    Rake::Task["canoe:create_dev_targets"].invoke
  end

  task :create_production_targets => :environment do
    Rake::Task["canoe:create_prod_targets"].invoke
  end

end
