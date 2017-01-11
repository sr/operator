module BuildsHelper
  def shipit_btn_class(build)
    if build.passed_ci?
      "btn-primary"
    else
      "btn-danger"
    end
  end
end
