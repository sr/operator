module BuildsHelper
  def shipit_btn_class(build)
    if build.passed_ci?
      "btn-primary"
    else
      "btn-danger"
    end
  end

  def shipit_btn_disabled(build, allow_pending_builds)
    !build.compliance_allows_deploy? || \
      !allow_pending_builds && !build.passed_ci?
  end

  def shipit_btn_title(build, allow_pending_builds)
    if !allow_pending_builds && !build.passed_ci?
      "The primary build is pending or has failed"
    elsif !build.compliance_allows_deploy?
      build.compliance_description
    end
  end
end
