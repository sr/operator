require 'cgi'

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
  # HTML Helpers
  def deploy_type_icon(type)
    content_tag :i, "", class: deploy_icon_class(type)
  end

  def deploy_icon_class(type)
    case type
    when "build" then "icon-archive"
    when "tag" then "icon-tag"
    when "branch-master" then "icon-code"
    when "branch" then "icon-code-fork"
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
    time.in_time_zone.strftime("%m/%d/%y @ %l:%M %p")
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

  def kibana_link(deploy:, host: nil)
    query = [
      %(program:pull-agent),
      %(message:"deploy_id=#{deploy.id}")
    ]
    query << %(host:#{host}) if host

    qs = {
      query: query.join(" AND "),
      fields: "@timestamp,host,message"
    }.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v).gsub('+', '%20')}" }.join("&")

    "https://logs.#{'dev.' unless deploy.deploy_target.production?}pardot.com/#/dashboard/script/logstash.js?#{qs}"
  end
end