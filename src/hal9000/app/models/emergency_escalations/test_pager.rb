module EmergencyEscalations
  class TestPager
    def trigger(description)
      return unless description.include? "raise an error"
      raise StandardError, "an error occurred"
    end
  end
end
