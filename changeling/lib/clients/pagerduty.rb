module Clients
  class Pagerduty
    class Link
      def initialize(href, text)
        @href = href
        @text = text
      end

      def as_json
        {
          type: "link",
          href: @href,
          text: @text
        }
      end
    end

    EVENTS_HOSTNAME = "events.pagerduty.com".freeze

    def trigger(service_key:, incident_key:, description:, contexts: [])
      req = Net::HTTP::Post.new("/generic/2010-04-15/create_event.json")
      req.body = JSON.dump(
        service_key: service_key,
        incident_key: incident_key,
        description: description,
        contexts: contexts.map(&:as_json)
      )

      Net::HTTP.start(EVENTS_HOSTNAME, 443, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_PEER) do |http|
        resp = http.request(req)
        resp.value # raises error on non-successful responses
        resp
      end
    end
  end
end
