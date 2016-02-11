require "json"

module Lita
  module Handlers
    class ReplicationFixing < Handler
      http.post "/replication/errors", :create_replication_error

      def create_replication_error(request, response)
        json = JSON.parse(request.body.string)
        if json["mysql_last_error"]
          # TODO
          response.status = 201
        else
          response.status = 400
          response.body << JSON.dump("error" => "mysql_last_error missing")
        end
      end

      Lita.register_handler(self)
    end
  end
end
