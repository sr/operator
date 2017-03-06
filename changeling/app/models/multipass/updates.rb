# Handle various updates to multipass from the web forms
module Multipass::Updates
  def update_from_form(multipass_attributes = {})
    self.impact             = multipass_attributes["impact"]
    self.impact_probability = multipass_attributes["impact_probability"]
    self.change_type        = multipass_attributes["change_type"]
    self.testing            = multipass_attributes["testing"]
    self.backout_plan       = multipass_attributes["backout_plan"]
    check_commit_statuses! unless complete?
    save
  end
end
