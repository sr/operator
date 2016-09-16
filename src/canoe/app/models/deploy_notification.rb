class DeployNotification < ApplicationRecord
  PRODUCTION_COLOR = "purple".freeze
  NON_PRODUCTION_COLOR = "gray".freeze
  UNTESTED_COLOR = "red".freeze

  belongs_to :project

  # For injecting a fake during test
  attr_writer :notifier

  def notify_deploy_start(deploy)
    server_count = deploy.all_servers.size
    server_msg = \
      if server_count > 3
        "#{server_count} servers"
      else
        deploy.all_servers.join(", ")
      end

    msg = "#{deploy.deploy_target.name.capitalize}: #{deploy.auth_user.email} " \
      "just began syncing #{deploy.project_name.capitalize} to " \
      "#{build_link(deploy)} [#{server_msg}]"

    previous_deploy = deploy.deploy_target.previous_deploy(deploy)
    msg += "<br>GitHub Diff: <a href='#{deploy.project.diff_url(previous_deploy, deploy)}'>" \
      "#{build_link(previous_deploy, false)} ... #{build_link(deploy, false)}" \
      "</a>" if previous_deploy

    notifier.notify_room(
      hipchat_room_id,
      msg,
      color: deploy.deploy_target.production? ? PRODUCTION_COLOR : NON_PRODUCTION_COLOR
    )
  end

  def notify_deploy_complete(deploy)
    msg = "#{deploy.deploy_target.name.capitalize}: #{deploy.auth_user.email} " \
      "just finished syncing #{deploy.project_name.capitalize} to #{build_link(deploy)}"

    notifier.notify_room(
      hipchat_room_id,
      msg,
      color: deploy.deploy_target.production? ? PRODUCTION_COLOR : NON_PRODUCTION_COLOR
    )
  end

  def notify_deploy_cancelled(deploy)
    msg = "#{deploy.deploy_target.name.capitalize}: #{deploy.auth_user.email} just " \
      "CANCELLED syncing #{deploy.project_name.capitalize} to #{build_link(deploy, false)}"

    notifier.notify_room(
      hipchat_room_id,
      msg,
      color: deploy.deploy_target.production? ? PRODUCTION_COLOR : NON_PRODUCTION_COLOR
    )
  end

  def notify_untested_deploy(deploy)
    msg = "#{deploy.deploy_target.name.capitalize}: #{deploy.auth_user.email} just started " \
      "an UNTESTED deploy of #{deploy.project_name.capitalize} to #{build_link(deploy, false)}"

    notifier.notify_room(
      hipchat_room_id,
      msg,
      color: UNTESTED_COLOR
    )
  end

  def notifier
    @notifier ||= HipchatNotifier.new
  end

  private

  def build_link(deploy, link = true)
    if deploy.branch == "master"
      build_txt = "build#{deploy.build_number}"
    else
      build_txt = "#{deploy.branch} build#{deploy.build_number}"
    end
    commit_link = project.commit_url(deploy)
    link ? "<a href='#{commit_link}'>#{build_txt}</a>" : build_txt
  end
end
