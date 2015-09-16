require 'socket'

Deploy = Struct.new(:what, :what_details, :build_number, :artifact_url, :servers) do
  def self.from_hash(hash)
    new(
      hash["what"],
      hash["what_details"],
      hash["build_number"],
      hash["artifact_url"],
      hash["servers"]
    )
  end

  def applies_to_this_server?
    servers && servers.include?(short_hostname)
  end

  private
  def short_hostname
    Socket.gethostname.sub(/\.pardot\.com$/, "")
  end
end
