# Defines conditional requirements for multipasses
module Multipass::RequiredFields
  MANDATORY_REQUIRED_FIELDS = [
    :reference_url,
    :requester,
    :impact,
    :impact_probability,
    :change_type,
    :testing,
    :backout_plan
  ].freeze

  CONDITIONAL_REQUIRED_FIELDS = {
    ChangeCategorization::STANDARD => [:peer_reviewer],
    ChangeCategorization::MAJOR => [:sre_approver, :peer_reviewer],
    ChangeCategorization::EMERGENCY => []
  }.freeze

  def missing_fields
    missing_mandatory_fields + missing_conditional_fields
  end

  def missing_mandatory_fields
    MANDATORY_REQUIRED_FIELDS.select do |f|
      !self.send(f).present?
    end
  end

  def missing_conditional_fields
    return [] if change_type.nil?
    conditional_fields.select do |f|
      !self.send(f).present?
    end
  end

  def conditional_fields
    CONDITIONAL_REQUIRED_FIELDS.fetch(change_type)
  end

  def required_field?(actor)
    CONDITIONAL_REQUIRED_FIELDS.fetch(change_type).include?(actor.to_sym)
  end

  def enabled_actor?(actor, version = 1)
    if version.to_s != "1"
      required_field?(actor) || actor == "rejector" || actor == "emergency_approver"
    else
      required_field?(actor) || actor == "rejector"
    end
  end

  def locking_field?(actor, version = 1)
    locking_fields_for(version).include? actor.to_sym
  end

  def locking_fields_for(version = 1)
    if version.to_s != "1"
      [:rejector, :emergency_approver]
    else
      [:rejector]
    end
  end
end
