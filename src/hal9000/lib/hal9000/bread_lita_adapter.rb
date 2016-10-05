require "lita"
require "grpc"

module Hal9000
  class BreadLitaAdapter < Lita::Adapter
    namespace :bread

    config :token, type: String, required: true
    config :server, type: String, required: true
    config :address, type: String, required: true

    def initialize(robot)
      super

      @hipchat = HipChat::Client.new(config.token,
        api_version: "v2",
        server_url: config.server
      )
    end

    def run
      server = GRPC::RpcServer.new
      server.add_http2_port(config.address, :this_port_is_insecure)
      server.handle(RobotServer.new(robot))
      server.run_till_terminated
    end

    def send_messages(source, messages)
      messages.each do |message|
        # rubocop:disable Style/Send
        @hipchat[source.room].send(robot.name, message,
          color: "yellow",
          message_format: "html"
        )
      end
    end

    Lita.register_adapter(:bread, self)
  end
end
