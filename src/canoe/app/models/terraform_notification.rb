class TerraformNotification
  YELLOW = "yellow".freeze

  def initialize(notifier, room_ids)
    @notifier = notifier
    @room_ids = room_ids
  end

  def deploy_started(deploy)
    message = "#{deploy.user_name} is deploying terraform " \
      "<code>#{deploy.commit_sha1}@#{deploy.branch_name}</code> with " \
      "<code>#{deploy.terraform_version}</code> to " \
      "<code>#{deploy.estate_name}</code>"

    @room_ids.each do |room_id|
      @notifier.notify_room(room_id, message, color: YELLOW)
    end
  end
end
