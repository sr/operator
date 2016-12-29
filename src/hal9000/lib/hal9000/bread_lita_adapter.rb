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

      run_thread = Thread.new do
        @server.run
      end

      @server.wait_till_running
      Lita.logger.info "HAL9000 gRPC server started on #{config.address}"
      robot.trigger(:connected)
      run_thread.join
    end

    def shut_down
      @server.stop
      robot.trigger(:disconnected)
    end

    def mention_format(name)
      if name.empty?
        return ""
      end

      "@#{name}"
    end

    # rubocop:disable Style/Send
    def send_messages(source, messages)
      $stderr.puts "DEBUG: source=#{source.inspect} messages=#{messages.map(&:size)}"

      if source.private_message? && source.user.id.to_s.empty?
        raise Error, "Unable to send private message without a source user: #{source.inspect}"
      end

      if !source.private_message? && source.room.to_s.empty?
        raise Error, "Unable to send room message without a source room: #{source.inspect}"
      end

      messages.each do |message|
        # If it's a private message, force format to be text. For some reason
        # only plain text private messages open a new conversation tab.
        if source.private_message?
          options = { message_format: "text", color: "yellow", notify: true }
          response = @hipchat.user(source.user.id).send(message, options.merge(notify: true))
          $stderr.puts "HipChat API returned:\n HTTP error code #{response.code}\n #{response.body}" if !response.code =~ /2../
        else
          if !message.start_with?("<!-- #html -->")
            message = message.gsub("\n", "<br>")
          end

          @hipchat[source.room].send("", message[0, 9999], options)
        end
      end
    end

    Lita.register_adapter(:bread, self)
  end
end
