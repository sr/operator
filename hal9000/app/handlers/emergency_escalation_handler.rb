require "emergency_escalations/pagerduty_pager"

class EmergencyEscalationHandler < ApplicationHandler
  # config: Pagerduty
  config :pager, default: "pagerduty"
  config :pagerduty_service_key

  route(/^emergency(?:\s+(?<reason>.+))?$/i, :emergency_page, command: true, help: {
          "emergency <optional info about the incident>" => "Pages the Incident Response escalation group for a Sev0/1 incident"
        })

  def initialize(robot)
    super
    @pager = \
      case config.pager.to_s
      when "test"
        ::EmergencyEscalations::TestPager.new
      when "pagerduty"
        ::EmergencyEscalations::PagerdutyPager.new(config.pagerduty_service_key)
      else
        raise ArgumentError, "unknown pager type: #{config.pager}"
      end
  end

  def emergency_page(response)
    if response.match_data["reason"].nil? || response.match_data["reason"].empty?
      @pager.trigger("SRE/CCE has been paged for a critical incident response")
    else
      @pager.trigger("SRE/CCE has been paged for a critical incident: #{response.match_data["reason"]}")
    end
    response.reply_with_mention("SRE/CCE Incident Response on-call person has been paged")
  rescue => e
    response.reply_with_mention("paging the SRE/CCE Incident Response on-call failed: #{e.message}")
  end
end
