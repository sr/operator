module TargetsHelper
  def repo_row_class(lock, deploy)
    if deploy && !deploy.completed?
      "warning"
    elsif lock
      "danger"
    else
      "info"
    end
  end
end
