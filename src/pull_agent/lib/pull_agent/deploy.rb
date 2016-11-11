module PullAgent
  Deploy = Struct.new(:id, :branch, :build_number, :artifact_url, :server_actions, :created_at, :sha, :options) do
    def self.from_hash(hash)
      new(
        hash["id"],
        hash["branch"],
        hash["build_number"],
        hash["artifact_url"],
        hash["servers"],
        hash["created_at"],
        hash["sha"],
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

    def to_build_version
      BuildVersion.new(build_number, sha, artifact_url)
    end

    def servers
      server_actions.keys
    end
  end
end
