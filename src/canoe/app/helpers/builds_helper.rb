module BuildsHelper
  def shipit_btn_class(build)
    if build.tests_state != GithubRepository::SUCCESS
      "btn-danger"
    else
      "btn-primary"
    end
  end

  def shipit_btn_disabled(build, allow_failed_builds)
    !build.compliance_allows_deploy? || \
      !allow_failed_builds && build.tests_state != GithubRepository::SUCCESS
  end

  def shipit_btn_title(build, allow_failed_builds)
    if !allow_failed_builds && build.tests_state != GithubRepository::SUCCESS
      "The primary build failed"
    elsif !build.compliance_allows_deploy?
      build.compliance_description
    end
  end
end
