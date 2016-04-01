require "thread"

module Instrumentation
  module RequestId
    REQUEST_ID = :instrumentation_request_id

    def request_id
      Thread.current[REQUEST_ID]
    end

    def request_id=(value)
      Thread.current[REQUEST_ID] = value
    end

    module_function :request_id, :request_id=

    class RackMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        RequestId.request_id = nil

        if id = env["HTTP_X_REQUEST_ID"]
          RequestId.request_id = id
        end

        @app.call(env)
      end
    end
  end
end
