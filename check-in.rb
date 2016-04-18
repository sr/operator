#!/usr/bin/env ruby
$:.unshift File.realpath(File.dirname(__FILE__), "lib")

require 'rubygems'
require 'bundler/setup'

require "pardot/pull_agent"

LOCKFILE = '/var/lock/pull-agent/deploy.lock'.freeze

proxy_selector = Pardot::PullAgent::ProxySelector.new
proxy_selector.configure_random_proxy

cli = Pardot::PullAgent::CLI.new
cli.parse_arguments!
environment = cli.environment

# Wait a random number of seconds, since cron can't be set by second
sleep(rand*60) unless environment.dev?

# Only one-concurrent process using file lock
lockfile = File.new(LOCKFILE, 'w')
begin
  if lockfile.flock(File::LOCK_NB|File::LOCK_EX)
    cli.checkin
  else
    Pardot::PullAgent::Logger.log(:error, "#{LOCKFILE} is locked. Is another process already running?")
  end
rescue => e
  Pardot::PullAgent::Logger.log(:alert, e.to_s + "\n" + e.backtrace.join("\n"))
  raise e
ensure
  lockfile.close
end
