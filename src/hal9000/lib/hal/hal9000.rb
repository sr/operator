# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: hal/hal9000.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "hal.Message" do
    optional :text, :string, 1
    optional :user_email, :string, 2
    optional :room, :string, 3
  end
  add_message "hal.IsMatchResponse" do
    optional :match, :bool, 1
  end
  add_message "hal.DispatchResponse" do
  end
end

module Hal
  Message = Google::Protobuf::DescriptorPool.generated_pool.lookup("hal.Message").msgclass
  IsMatchResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("hal.IsMatchResponse").msgclass
  DispatchResponse = Google::Protobuf::DescriptorPool.generated_pool.lookup("hal.DispatchResponse").msgclass
end
