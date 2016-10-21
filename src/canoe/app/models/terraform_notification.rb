class TerraformNotification
  YELLOW = "yellow".freeze
  GREEN = "green".freeze
  RED = "red".freeze

  def initialize(notifier, room_ids)
    @notifier = notifier
    @room_ids = room_ids
  end

  def deploy_started(deploy)
    message = "#{deploy.user_name} is deploying terraform " \
      "<code>#{deploy.commit_sha1[0, 7]}@#{deploy.branch_name}</code> with " \
      "<code>#{deploy.terraform_version}</code> to " \
      "<code>#{deploy.estate_name}</code>"

    notify(message, YELLOW)
  end

  def deploy_complete(deploy)
    message = "#{deploy.user_name}'s terraform deployment of " \
      "<code>#{deploy.commit_sha1[0, 7]}@#{deploy.branch_name}</code> to " \
      "<code>#{deploy.estate_name}</code> "

    if deploy.successful?
      color = GREEN
      message += "is done"
    else
      color = RED
      message += "failed"
    end

    notify(message, color)
  end

  private

  def notify(message, color)
    @room_ids.each do |room_id|
      @notifier.notify_room(room_id, message, color: color)
    end
  end
end
