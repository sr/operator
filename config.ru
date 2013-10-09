CANOE_DIR=File.dirname(__FILE__)
ENV["CANOE_DIR"]=CANOE_DIR
ENV["RACK_ENV"]="development"

# add our root and lib dirs to the load path
$:.unshift CANOE_DIR
$:.unshift "#{CANOE_DIR}/lib/"

require "app"

run CanoeApplication
