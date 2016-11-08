require "cgi"

# rubocop:disable Rails/OutputSafety
module CanoeHelper
  def protocol_for_includes
    request.scheme
  end

  # ----------------------------------------------------------------------
  # DATA

  # ----------------------------------------------------------------------
  # ACTIVE X
  def active_project(project = nil)
    current_project_name = current_project && current_project.name
    project_name = project && project.name

    current_project_name == project_name ? 'class="active"'.html_safe : ""
  end

  def active_target(target_name = "")
    if !current_project && current_target && \
       current_target.name.casecmp(target_name.downcase).zero?
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
    "<span title='#{sha}' class='js-sha-expand' data-sha='#{sha}'>#{sha[0, 8]}...</span>".html_safe
  end

  # ----------------------------------------------------------------------
  # PRINT
  def print_deploy_what(deploy)
    output = deploy_type_icon("branch")
    output += " "
    output += deploy.branch

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
      "#{seconds} second#{seconds == 1 ? "" : "s"}"
    elsif minutes < 60
      "#{minutes} minute#{minutes == 1 ? "" : "s"}"
    else
      hours = minutes / 60.0
      "#{"%0.1f" % hours} hour#{hours == 1 ? "" : "s"}"
    end
  end

  def print_email(email)
    pieces = email.split("@")
    output = pieces[0]
    output += "<span class='muted'>@#{pieces[1]}</span>" if pieces[1]
    output.html_safe
  end

  def kibana_link(deploy:, datacenter:, host: nil)
    query = [
      %(program:pull-agent),
      %(message:"deploy_id=#{deploy.id}")
    ]
    query << %(host:#{host}*) if host
    qs = CGI.escape(query.join(" AND ")).gsub("+", "%20")

    "https://logs-#{datacenter}.pardot.com/app/kibana#/discover?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:now-1h,mode:quick,to:now))&_a=(columns:!(_source),index:'logstash-*',interval:auto,query:(query_string:(analyze_wildcard:!t,query:'#{qs}')),sort:!('@timestamp',desc))"
  end
end
