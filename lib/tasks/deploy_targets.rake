namespace :canoe do

  desc 'Create deploy targets for dev env'
  task :create_dev_targets => :environment do
    dev = DeployTarget.where(name: 'dev').first
    DeployTarget.create(
      name: 'dev',
      script_path: "#{Rails.root}/../sync_scripts",
      lock_path: "#{Rails.root}/../sync_scripts/dev_lock",
      locked: false,
    ) if !dev

    test = DeployTarget.where(name: 'test').first
    DeployTarget.create(
      name: 'test',
      script_path: "#{Rails.root}/../sync_scripts",
      lock_path: "#{Rails.root}/../sync_scripts/dev_lock",
      locked: true,
    ) if !test
  end

  desc 'Create deploy targets for test/staging envs'
  task :create_staging_targets => :environment do
    testing_env = DeployTarget.where(name: 'test').first
    DeployTarget.create(
      name: 'test',
      script_path: '/opt/sync/test',
      lock_path: '/var/lock/test',
      locked: false,
    ) if !testing_env

    staging_env = DeployTarget.where(name: 'staging').first
    DeployTarget.create(
      name: 'staging',
      script_path: '/opt/sync/staging',
      lock_path: '/var/lock/staging',
      locked: false,
    ) if !staging_env
  end

  desc 'Create deploy targets for new-staging env'
  task :create_new_staging_targets => :environment do
    staging_env = DeployTarget.where(name: 'staging').first
    DeployTarget.create(
      name: 'staging',
      script_path: '/opt/sync/staging',
      lock_path: '/var/lock/staging',
      locked: false,
    ) if !staging_env

    engage_env = DeployTarget.where(name: 'engagement').first
    DeployTarget.create(
      name: 'engagement',
      script_path: '/opt/sync/staging',
      lock_path: '/var/lock/engagement',
      locked: false,
    ) if !engage_env
  end

  desc "Create deploy target for production env"
  task :create_prod_targets => :environment do
    prod_env = DeployTarget.where(name: "production").first
    DeployTarget.create(
      name: "production",
      script_path: "/opt/sync/production",
      lock_path: "/var/lock/production",
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
