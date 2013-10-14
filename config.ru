CANOE_DIR=File.expand_path(File.dirname(__FILE__))
ENV["CANOE_DIR"]=CANOE_DIR
ENV["RACK_ENV"]="production"

# add our root and lib dirs to the load path
$:.unshift CANOE_DIR
$:.unshift "#{CANOE_DIR}/lib/"
$:.unshift "#{CANOE_DIR}/lib/models/"

require "app"

run CanoeApplication
