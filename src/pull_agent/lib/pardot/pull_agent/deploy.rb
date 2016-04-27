module Pardot
  module PullAgent
    Deploy = Struct.new(:id, :what, :what_details, :build_number, :artifact_url, :server_actions, :created_at, :options) do
      def self.from_hash(hash)
        new(
          hash["id"],
          hash["what"],
          hash["what_details"],
          hash["build_number"],
          hash["artifact_url"],
          hash["servers"],
          hash["created_at"],
          hash["options"]
        )
      end

      def applies_to_this_server?
        server_actions && server_actions.key?(ShellHelper.hostname)
      end

      def action
        if server_actions && server_actions[ShellHelper.hostname]
          server_actions[ShellHelper.hostname]["action"]
        end
      end

      def servers
        server_actions.keys
      end
    end
  end
end
