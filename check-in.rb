#!/usr/bin/env ruby

require 'pathname'

LOCKFILE='/tmp/pull-lock'
SYNC_SCRIPTS_DIR=File.realpath(File.dirname(__FILE__))
# add our root and lib dirs to the load path
$:.unshift SYNC_SCRIPTS_DIR
$:.unshift "#{SYNC_SCRIPTS_DIR}/lib/"
$:.unshift "#{SYNC_SCRIPTS_DIR}/lib/helpers/"
$:.unshift "#{SYNC_SCRIPTS_DIR}/lib/core_ext/"

# ---------------------------------------------------------------------------
require 'cli'
require 'canoe'

cli = CLI.new
cli.setup

# Wait a random number of seconds, since cron can't be set by second
sleep(rand*30) unless cli.environment.dev?

# Only one-concurrent process using file lock
lockfile = File.new(LOCKFILE, 'w')
lockfile.flock(File::LOCK_NB|File::LOCK_EX) or abort("#{LOCKFILE} is locked. Is another process already running?")

begin
  currently_deployed = cli.check_version
  requested, artifact_url = Canoe.get_current_build(cli.environment)

  if currently_deployed != requested
    Console.log("Current: #{currently_deployed || "<None>"} -> Requested: #{requested}")
    cli.options[:requested_value] = requested
    cli.options[:artifact_url] = artifact_url
    cli.start!
  else
    Console.log("We're up to date: #{requested}", :green)
  end
rescue => e
  Console.syslog(e.to_s, :alert)
  raise e
ensure
  lockfile.close
end
