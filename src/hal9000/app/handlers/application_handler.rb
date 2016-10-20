class ApplicationHandler
  extend Lita::Handler::ChatRouter
  extend Lita::Handler::EventRouter

  def self.http
    raise NotImplementedError, "Lita HTTP routes are not supported. Please talk to the BREAD team for guidance: https://sfdc.co/pd-bread-comms"
  end
end
