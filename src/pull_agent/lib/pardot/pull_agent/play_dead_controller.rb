require "net/http"

module Pardot
  module PullAgent
    class PlayDeadController
      def initialize(admin_port = 8090)
        @admin_port = admin_port
      end

      def make_play_dead
        Net::HTTP.start("localhost", @admin_port) do |http|
          req = Net::HTTP::Put.new("/admin-tools/ready")
          http.request(req).value
        end
      rescue Errno::ECONNREFUSED
        # The service is already dead as far as we know
        true
      end

      def make_alive
        Net::HTTP.start("localhost", @admin_port) do |http|
          req = Net::HTTP::Delete.new("/admin-tools/ready")
          http.request(req).value
        end
      end
    end
  end
end
