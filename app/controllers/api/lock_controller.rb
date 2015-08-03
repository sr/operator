class Api::LockController < Api::Controller
  def status
    @targets = all_targets
  end
end
