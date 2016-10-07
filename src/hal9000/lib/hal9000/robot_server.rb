require "lita"
require "hal9000/hal9000_services"

module Hal9000
  class RobotServer < Robot::Service
    def initialize(robot)
      @robot = robot
    end

    # rubocop:disable Style/PredicateName
    def is_match(request, _call)
      exception_logger do
        Lita.logger.info "Received hal9000.IsMatch request: #{request.inspect}"

        message = build_message(request)

        ok = @robot.handlers.any? { |handler|
          next unless handler.respond_to?(:dispatch)
          handler.routes.any? do |route|
            handler.__send__(:route_applies?, route, message, @robot)
          end
        }

        Hal9000::Response.new(match: ok)
      end
    end

    def dispatch(request, _call)
      exception_logger do
        Lita.logger.info "Received hal9000.Dispatch request: #{request.inspect}"

        @robot.receive(build_message(request))

        Hal9000::Response.new
      end
    end

    private

    def exception_logger
      yield
    rescue
      Lita.logger.error "Got an exception in RobotServer: #{$!.inspect}"
      Lita.logger.error $!.backtrace.join("\n")

      raise
    end

    def build_message(request)
      user = Lita::User.new(request.user.email.dup, "name": request.user.name.dup)
      source = Lita::Source.new(user: user, room: request.room.dup)

      Lita::Message.new(@robot, request.text.dup, source)
    end

    def adapter
      @robot.__send__(:adapter)
    end
  end
end
