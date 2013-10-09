#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

CANOE_DIR=File.dirname(__FILE__)
ENV["CANOE_DIR"]=CANOE_DIR

$:.unshift CANOE_DIR
$:.unshift "#{CANOE_DIR}/lib/"

require "app"
require "sinatra/activerecord/rake"
