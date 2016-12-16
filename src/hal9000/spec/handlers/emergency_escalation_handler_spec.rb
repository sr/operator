require "spec_helper"

describe EmergencyEscalationHandler, lita_handler: true do
  before do
    registry.config.handlers.emergency_escalation_handler.pager = "test"
  end

  describe "emergency" do
    it "generates an incident with no arguments to the command" do
      send_command("emergency")
      expect(replies.last).to match(/^.*SRE\/CCE Incident Response on-call person has been paged$/)
    end

    it "generates an incident with arguments to the command" do
      send_command("emergency stuff is broken")
      expect(replies.last).to match(/^.*SRE\/CCE Incident Response on-call person has been paged$/)
    end

    it "returns a graceful error message when paging attempt fails" do
      send_command("emergency raise an error")
      expect(replies.last).to match(/^.*paging the SRE\/CCE Incident Response on-call failed: an error occurred$/)
    end
  end
end
