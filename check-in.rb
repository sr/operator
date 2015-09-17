#!/usr/bin/env ruby

require 'pathname'

LOCKFILE = '/tmp/pull-lock'
SYNC_SCRIPTS_DIR = File.realpath(File.dirname(__FILE__))
# add our root and lib dirs to the load path
$:.unshift SYNC_SCRIPTS_DIR
$:.unshift "#{SYNC_SCRIPTS_DIR}/lib/"
$:.unshift "#{SYNC_SCRIPTS_DIR}/lib/helpers/"
$:.unshift "#{SYNC_SCRIPTS_DIR}/lib/core_ext/"

# ---------------------------------------------------------------------------
require 'canoe'
require 'cli'
require 'build_version'

cli = CLI.new
cli.parse_arguments!
environment = cli.environment

# Wait a random number of seconds, since cron can't be set by second
sleep(rand*30) unless environment.dev?

# Only one-concurrent process using file lock
lockfile = File.new(LOCKFILE, 'w')
lockfile.flock(File::LOCK_NB|File::LOCK_EX) or abort("#{LOCKFILE} is locked. Is another process already running?")
begin
  current_build_version = BuildVersion.load(environment.payload.build_version_file)
  requested_deploy = Canoe.latest_deploy(environment)

  if requested_deploy.applies_to_this_server?
    if requested_deploy.completed
      Console.log("Latest deploy is marked as completed: #{requested_deploy}")
    elsif current_build_version && current_build_version.instance_of_deploy?(requested_deploy)
      Console.log("We are up to date: #{requested_deploy}")
    else
      Console.log("Current build: #{current_build_version || "<< None >>"}")
      Console.log("Requested deploy: #{requested_deploy}")

      conductor = environment.conductor
      conductor.deploy!(requested_deploy)
    end
  else
    Console.log("The latest deploy does not apply to this server: #{requested_deploy}", :green)
  end
rescue => e
  Console.syslog(e.to_s, :alert)
  raise e
ensure
  lockfile.close
end
