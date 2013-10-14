#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

CANOE_DIR=File.dirname(__FILE__)
ENV["CANOE_DIR"]=CANOE_DIR

$:.unshift CANOE_DIR
$:.unshift "#{CANOE_DIR}/lib/"
$:.unshift "#{CANOE_DIR}/lib/models/"

require "app"
require "sinatra/activerecord/rake"

# ----------------------------------------------------------------------------
namespace :canoe do

  desc 'Create deploy targets for dev env'
  task :create_dev_targets do
    user = AuthUser.first

    dev = DeployTarget.where(name: 'dev').first
    DeployTarget.create(
      name: 'dev',
      script_path: '/Users/sveader/Code/pardot/sync_scripts',
      lock_path: '/Users/sveader/Code/pardot/sync_scripts/dev_lock',
      locked: false,
    ) if !dev

    test = DeployTarget.where(name: 'test').first
    DeployTarget.create(
      name: 'test',
      script_path: '/Users/sveader/Code/pardot/sync_scripts',
      lock_path: '/Users/sveader/Code/pardot/sync_scripts/dev_lock',
      locked: true,
      locking_user_id: user.id,
    ) if !test
  end

  desc 'Create deploy targets for test/staging envs'
  task :create_staging_targets do
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

end