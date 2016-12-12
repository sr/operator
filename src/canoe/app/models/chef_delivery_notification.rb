class ChefDeliveryNotification
  YELLOW = "yellow".freeze
  GRAY = "gray".freeze
  GREEN = "green".freeze
  RED = "red".freeze

  def initialize(notifier, github_url, repo_name)
    @notifier = notifier
    @github_url = github_url
    @repo = repo_name
  end

  def at_lock_age_limit(room_id, server, checkout, deploy)
    # Disable messaging for chef1-2 servers until they're provisioned - OPS-5521
    return if /pardot0-chef1-2-*/ =~ server.hostname
    message = "chef/master #{link_to(deploy)} could not be deployed to "\
      "#{server.datacenter}/#{server.environment} because branch " \
      "#{link_to(checkout.branch)} is checked out on " \
      "<code>#{server.hostname}</code>"

    @notifier.notify_room(room_id, message, color: YELLOW)
  end

  def deploy_completed(room_id, deploy, error_message)
    # Disable messaging for chef1-2 servers until they're provisioned - OPS-5521
    return if /pardot0-chef1-2-*/ =~ deploy.hostname
    if deploy.successful?
      color = GREEN
      message = "chef/master #{link_to(deploy)} successfully deployed to " \
        "#{deploy.datacenter}/#{deploy.environment} on host " \
        "<code>#{deploy.hostname}</code>"
    else
      color = RED
      message = "chef/master #{link_to(deploy)} failed to deploy to " \
        "#{deploy.datacenter}/#{deploy.environment} " \
        "on host #{deploy.hostname}" \
        "<br/><pre>#{error_message}</pre>"
    end

    @notifier.notify_room(room_id, message, color: color)
  end

  def knife_command(room_id, server, command)
    message = "knife command executed in " \
      "#{server.datacenter}/#{server.environment} on " \
      "<code>#{server.hostname}</code>: <br/>" \
      "<code>knife #{command.join(" ")}</code>"

    @notifier.notify_room(room_id, message, color: GRAY)
  end

  private

  def link_to(object)
    case object
    when GithubCommitStatus
      build_id = object.tests_url.split("-").last
      %(<a href="#{object.tests_url}">##{build_id}</a>)
    when ChefDeploy
      %(<a href="#{object.build_url}">##{object.build_id}</a>)
    when String
      %(<a href="#{@github_url}/#{@repo}/compare/#{object}">#{object}</a>)
    else
      raise ArgumentError, "unable to link to #{object.inspect}"
    end
  end
end
