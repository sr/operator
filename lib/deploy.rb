require 'socket'

Deploy = Struct.new(:id, :what, :what_details, :build_number, :artifact_url, :completed, :servers) do
  def self.from_hash(hash)
    new(
      hash["id"],
      hash["what"],
      hash["what_details"],
      hash["build_number"],
      hash["artifact_url"],
      hash["completed"],
      hash["servers"]
    )
  end

  def this_server_hostname
    Socket.gethostname.sub(/\.pardot\.com$/, "")
  end

  def applies_to_this_server?
    servers && servers.include?(this_server_hostname)
  end
end
