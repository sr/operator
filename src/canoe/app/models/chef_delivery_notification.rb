class ChefDeliveryNotification
  YELLOW = "yellow".freeze
  GREEN = "green".freeze
  RED = "red".freeze

  def initialize(notifier, github_url, repo_name, room_id)
    @notifier = notifier
    @github_url = github_url
    @repo = repo_name
    @room = room_id
    @room_id = room_id
  end

  def at_lock_age_limit(checkout, build)
    message = "chef/master #{link_to(build)} not deployed to production " \
      "because branch #{link_to(checkout.branch)} is checked out on " \
      "<code>#{chef_server}</code>"

    @notifier.notify_room(@room_id, message, YELLOW)
  end

  def deploy_completed(deploy, success, error_message)
    if success
      color = GREEN
      message = "chef/master #{link_to(deploy)} successfully deployed to production"
    else
      color = RED
      message = "chef/master #{link_to(deploy)} failed to deploy to production" \
        "<br/><pre>#{error_message}</pre>"
    end

    @notifier.notify_room(@room_id, message, color)
  end

  private

  # TODO(sr) Configure this somewhere else?
  def chef_server
    "pardot0-chef1-1-dfw.ops.sfdc.net"
  end

  def link_to(object)
    case object
    when GithubRepository::Build
      # TODO(sr) Use the GitHub build ID instead of this hack?
      build_id = object.url.split("-").last
      %Q(<a href="#{object.url}">##{build_id}</a>)
    when GithubRepository::Deploy
      # TODO(sr) Link to the deploy's build
      %Q(<a href="https://boom">#52</a>)
    when String
      %Q(<a href="#{@github_url}/#{@repo}/compare/#{object}">#{object}</a>)
    else
      raise ArgumentError, "unable to link to #{object.inspect}"
    end
  end
end
