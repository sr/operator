require 'socket'

Deploy = Struct.new(:what, :what_details, :artifact_url, :servers) do
  def self.from_json(json)
    new(
      json["what"],
      json["what_details"],
      json["artifact_url"],
      json["servers"],
    )
  end

  def applies_to_this_server?
    servers.include?(short_hostname)
  end

  private
  def short_hostname
    Socket.gethostname.sub(/\.pardot\.com$/, "")
  end
end
