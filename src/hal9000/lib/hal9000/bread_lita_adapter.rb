require "lita"
require "grpc"

module Hal9000
  class BreadLitaAdapter < Lita::Adapter
    class Error < StandardError
    end

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

      @server = GRPC::RpcServer.new
      @server.add_http2_port(config.address, :this_port_is_insecure)
      @server.handle(RobotServer.new(robot))
    end

    def run
      Lita.logger.info "HAL9000 gRPC server starting on #{config.address} ..."

      @server.run_till_terminated
    end

    def shut_down
      @server.stop
    end

    # rubocop:disable Style/Send
    def send_messages(source, messages)
      if source.private_message? && source.user.id.to_s.empty?
        raise Error, "Unable to send private message without a source user: #{source.inspect}"
      end

      if !source.private_message? && source.room.to_s.empty?
        raise Error, "Unable to send room message without a source room: #{source.inspect}"
      end

      messages.each do |message|
        formatted_message = message.gsub("\n", "<br>")
        options = { message_format: "html", color: "yellow" }

        if source.private_message?
          @hipchat.user(source.user.id).send(formatted_message, options.merge(notify: true))
        else
          @hipchat[source.room].send("", formatted_message, options)
        end
      end
    end

    Lita.register_adapter(:bread, self)
  end
end
