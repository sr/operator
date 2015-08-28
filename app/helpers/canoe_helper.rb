module CanoeHelper
  def protocol_for_includes
    request.scheme
  end

  # ----------------------------------------------------------------------
  # DATA

  # ----------------------------------------------------------------------
  # ACTIVE X
  def active_repo(repo = nil)
    current_repo_name = current_repo && current_repo.name
    repo_name = repo && repo.name

    current_repo_name == repo_name ? 'class="active"'.html_safe : ''
  end

  def active_target(target_name="")
    if !current_repo && current_target && \
        current_target.name.downcase == target_name.downcase
      'class="active"'.html_safe
    else
      ""
    end
  end

  # ----------------------------------------------------------------------
  # PATHS
  def github_url
    "https://git.dev.pardot.com"
  end

  def github_tag_url(tag)
    "#{github_url}/#{current_repo.full_name}/releases/tag/#{tag.name}"
  end

  def github_branch_url(branch)
    "#{github_url}/#{current_repo.full_name}/tree/#{branch.name}"
  end

  def github_commit_url(commit)
    "#{github_url}/#{current_repo.full_name}/commits/#{commit.sha}"
  end

  def github_sha_url(sha)
    "#{github_url}/#{current_repo.full_name}/commits/#{sha}"
  end

  def github_diff_url(deploy1, deploy2)
    return "#" unless deploy1 && deploy2
    item1 = deploy1.branch? ? deploy1.sha : deploy1.what_details
    item2 = deploy2.branch? ? deploy2.sha : deploy2.what_details
    "#{github_url}/#{current_repo.full_name}/compare/#{item1}...#{item2}"
  end

  # ----------------------------------------------------------------------
  # HTML Helpers
  def deploy_type_icon(type)
    content_tag :i, "", class: deploy_icon_class(type)
  end

  def deploy_icon_class(type)
    case type
    when "build" then "icon-archive"
    when "tag" then "icon-tag"
    when "branch" then "icon-code-fork"
    when "commit" then "icon-tasks"
    else ""
    end
  end

  def sha_span(sha)
    "<span title='#{sha}' class='js-sha-expand' data-sha='#{sha}'>#{sha[0,8]}...</span>".html_safe
  end

  # ----------------------------------------------------------------------
  # PRINT
  def print_deploy_what(deploy)
    output = deploy_type_icon(deploy.what)
    output += " "
    if deploy.commit?
      output += sha_span(deploy.what_details)
    else
      output += deploy.what_details
    end

    if deploy.build_number
      output += " "
      output += deploy_type_icon("build")
      output += " "
      output += "build#{deploy.build_number}"
    end

    output.html_safe
  end

  def print_time(time)
    time.localtime.strftime("%m/%d/%y @ %l:%M %p")
  end

  def print_relative_time(time)
    time_delta = Time.now - time
    minutes = (time_delta / 60).round
    if minutes < 1
      seconds = time_delta.round
      "#{seconds} second#{seconds == 1 ? '' : 's'}"
    elsif minutes < 60
      "#{minutes} minute#{minutes == 1 ? '' : 's'}"
    else
      hours = minutes / 60.0
      "#{"%0.1f" % hours} hour#{hours == 1 ? '' : 's'}"
    end
  end

  def print_email(email)
    pieces = email.split("@")
    output = pieces[0]
    output += "<span class='muted'>@#{pieces[1]}</span>" if pieces[1]
    output.html_safe
  end
end
