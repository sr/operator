require "pagerduty"

module ReplicationFixing
  class PagerdutyPager
    def initialize(service_key)
      @client = ::Pagerduty.new(service_key)
    end

    def trigger(description, incident_key: nil)
      @client.trigger(description, incident_key: incident_key)
    end
  end
end
