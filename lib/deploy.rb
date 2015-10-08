require 'shell_helper'

Deploy = Struct.new(:id, :what, :what_details, :build_number, :artifact_url, :action, :servers) do
  def self.from_hash(hash)
    new(
      hash["id"],
      hash["what"],
      hash["what_details"],
      hash["build_number"],
      hash["artifact_url"],
      hash["action"],
      hash["servers"]
    )
  end

  def applies_to_this_server?
    servers && servers.include?(ShellHelper.hostname)
  end
end
