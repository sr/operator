module Zabbix
  class TestPager
    attr_reader :incidents

    def initialize
      @incidents = []
    end

    def trigger(description, incident_key: nil)
      @incidents << description
    end
  end
end
