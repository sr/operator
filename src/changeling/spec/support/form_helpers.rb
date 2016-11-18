module FormHelpers
  def submit_form(form = nil)
    if form
      find("##{form} input[name='commit']").click
    else
      find("input[name='commit']").click
    end
  end

  def submit_emergency
    find("#multipass_emergency_approver_form input[name='commit']").click
  end
end
