module ReplicationFixing
  # Add top-level class documentation comment here.
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
