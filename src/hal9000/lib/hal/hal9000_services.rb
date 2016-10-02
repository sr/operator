# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: hal/hal9000.proto for package 'hal'

require 'grpc'
require 'hal/hal9000'

module Hal
  module Robot
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'hal.Robot'

      rpc :IsMatch, Message, Response
      rpc :Dispatch, Message, Response
    end

    Stub = Service.rpc_stub_class
  end
end
