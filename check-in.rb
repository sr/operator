#!/usr/bin/env ruby

require 'pathname'

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
currently_deployed = cli.check_version
requested = Canoe.get_current_build(cli.environment)

if currently_deployed != requested
  Console.log("Current: #{currently_deployed || "<None>"} -> Requested: #{requested}")
  cli.options[:requested_value] = requested
  cli.start!
else
  Console.log("We're up to date: #{requested}", :green)
end