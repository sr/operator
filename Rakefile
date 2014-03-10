#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

CANOE_DIR=File.dirname(__FILE__)
ENV["CANOE_DIR"]=CANOE_DIR

$:.unshift CANOE_DIR
$:.unshift "#{CANOE_DIR}/lib/"
$:.unshift "#{CANOE_DIR}/lib/models/"
$:.unshift "#{CANOE_DIR}/lib/helpers/"

require "rubygems"
require "bundler/setup"
require "rake/testtask"
require "app"
require "sinatra/activerecord/rake"

task :default => [:test]

# ----------------------------------------------------------------------------
namespace :canoe do

  desc 'Run the given command as a job'
  task :run_job do
    job = TargetJob.where(id: ENV["JOB_ID"].to_i).first

    return unless job

    # fork off our job to run...
    job_pid = spawn(job.command)
    job.update_attribute(:process_id, job_pid)

    # wait for the child process to complete...
    waitpid(job_pid, Process::WNOHANG)

    job.complete!
  end

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

  desc 'Create deploy targets for new-staging env'
  task :create_new_staging_targets do
    staging_env = DeployTarget.where(name: 'staging').first
    DeployTarget.create(
      name: 'staging',
      script_path: '/opt/sync/staging',
      lock_path: '/var/lock/staging',
      locked: false,
    ) if !staging_env
  end

end

# ----------------------------------------------------------------------------
namespace :cover_me do
  desc 'Generates and opens code coverage report.'
  task :report do
    require 'cover_me'
    # CoverMe.config.root = REP_SCRIPTS_DIR
    CoverMe.config.file_pattern = [
      /(canoe\/lib\/.+\.rb)/i,
    ]
    CoverMe.complete!
  end

  desc "Clean up old coverage data"
  task :cleanup do
    `rm -f coverage.data`
    # File.delete("coverage.data") if File.exists?("coverage.data")
    `rm -rf coverage` #if File.exists?("coverage")
  end
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = FileList['test/*_test.rb']
  test.verbose = true
  test.warning = true
  # Rake::Task['cover_me:report'].invoke
end

desc 'Run tests and make sure all the test coverage is updated'
task :all do
  Rake::Task['cover_me:cleanup'].invoke
  Rake::Task['test'].invoke
  Rake::Task['cover_me:report'].invoke
end
