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
require 'shell_helper'

cli = CLI.new
cli.parse_arguments!
environment = cli.environment

# Wait a random number of seconds, since cron can't be set by second
sleep(rand*30) unless environment.dev?

# Only one-concurrent process using file lock
lockfile = File.new(LOCKFILE, 'w')
lockfile.flock(File::LOCK_NB|File::LOCK_EX) or abort("#{LOCKFILE} is locked. Is another process already running?")
begin
  cli.checkin
rescue => e
  Console.syslog(e.to_s + "\n" + e.backtrace.join("\n"), :alert)
  raise e
ensure
  lockfile.close
end
