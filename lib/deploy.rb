require 'shell_helper'

Deploy = Struct.new(:id, :what, :what_details, :build_number, :artifact_url, :server_actions) do
  def self.from_hash(hash)
    new(
      hash["id"],
      hash["what"],
      hash["what_details"],
      hash["build_number"],
      hash["artifact_url"],
      hash["servers"]
    )
  end

  def applies_to_this_server?
    server_actions && server_actions.key?(ShellHelper.hostname)
  end

  def action
    if server_actions && server_actions[ShellHelper.hostname]
      server_actions[ShellHelper.hostname]["action"]
    else
      nil
    end
  end

  def servers
    server_actions.keys
  end
end
