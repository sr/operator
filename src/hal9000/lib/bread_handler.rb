class BreadHandler < Lita::Handler
  def initialize(robot)
    super
    @hipchat = HipChat::Client.new(config.token, :api_version => 'v2', :server_url => config.url)
  end

  class RobotServer < Hal::Robot::Service
    def initialize(robot)
      @robot = robot
    end

    def is_match(request)
      @robot.routes.any? do |route|
        adapter.__send__(:route_applies?, route, message, @robot)
      end
    end

    def dispatch(message)
      user = Lita::User.new(message.user_email)
      source = Lita::Source.new(user: user, room: message.room)
      message = Lita::Message.new(@robot, message, source)
      @robot.receive(message)
    end

    private

    def adapter
      @robot.__send__(:adapter)
    end
  end

  def run
    s = GRPC::RpcServer.new
    s.add_http2_port(port, :this_port_is_insecure)
    s.handle(RobotServer.new(self, robot))
    s.run_till_terminated
  end

  def send_messages(source, messages)
    messages.each do |msg|
      @hipchat[source.room].send("HAL9000", message, {
        color: "yellow",
        message_format: "html",
      })
    end
  end
end
