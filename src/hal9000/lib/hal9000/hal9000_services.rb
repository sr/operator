# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: hal9000/hal9000.proto for package 'hal9000'
# rubocop:disable all

require 'grpc'
require 'hal9000/hal9000'

module Hal9000
  module Robot
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'hal9000.Robot'

      rpc :IsMatch, Message, Response
      rpc :Dispatch, Message, Response
      rpc :CreateRepfixError, CreateRepfixErrorRequest, CreateRepfixErrorResponse
    end

    Stub = Service.rpc_stub_class
  end
end
