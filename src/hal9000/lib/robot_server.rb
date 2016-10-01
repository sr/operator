require "lita"
require "hal/hal9000_services"

class RobotServer < Hal::Robot::Service
  def initialize(robot)
    @robot = robot
  end

  def is_match(request, _call)
    exception_logger do
      message = build_message(request)

      ok = @robot.handlers.map do |handler|
        next unless handler.respond_to?(:dispatch)
        handler.routes.any? do |route|
          handler.__send__(:route_applies?, route, message, @robot)
        end
      end.any?

      Hal::IsMatchResponse.new(match: ok)
    end
  end

  def dispatch(request, _call)
    exception_logger do
      @robot.receive(build_message(request))

      Hal::DispatchResponse.new
    end
  end

  private

  def exception_logger
    yield
  rescue
    @robot.logger.error "Got an exception in RobotServer: #{$!.inspect}"
    @robot.logger.error $!.backtrace.join("\n")
  end

  def build_message(request)
    user = Lita::User.new(request.user_email.dup)
    source = Lita::Source.new(user: user, room: request.room.dup)

    Lita::Message.new(@robot, request.text.dup, source)
  end

  def adapter
    @robot.__send__(:adapter)
  end
end
