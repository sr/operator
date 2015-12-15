#!/usr/bin/env ruby
$:.unshift File.realpath(File.dirname(__FILE__), "lib")

require 'rubygems'
require 'bundler/setup'

require 'pathname'
require 'cli'
require 'logger'

LOCKFILE = '/var/lock/pull-agent/deploy.lock'.freeze

cli = CLI.new
cli.parse_arguments!
environment = cli.environment

# Wait a random number of seconds, since cron can't be set by second
sleep(rand*60) unless environment.dev?

# Only one-concurrent process using file lock
lockfile = File.new(LOCKFILE, 'w')
lockfile.flock(File::LOCK_NB|File::LOCK_EX) or abort("#{LOCKFILE} is locked. Is another process already running?")
begin
  cli.checkin
rescue => e
  Logger.log(:alert, e.to_s + "\n", e.backtrace.join("\n"))
  raise e
ensure
  lockfile.close
end
