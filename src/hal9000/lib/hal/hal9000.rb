# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: hal/hal9000.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "hal.Message" do
    optional :text, :string, 1
    optional :user_email, :string, 2
    optional :room, :string, 3
  end
  add_message "hal.Response" do
    optional :match, :bool, 1
  end
end

module Hal
  Message = Google::Protobuf::DescriptorPool.generated_pool.lookup("hal.Message").msgclass
  Response = Google::Protobuf::DescriptorPool.generated_pool.lookup("hal.Response").msgclass
end
