require "uri"
require "net/http"

class Hipchat
  SUPPORT_ROOM = "support".freeze
  ENG_ROOM     = "engineering".freeze

  class << self
    def notify_deploy_start(deploy)
      return if Rails.env.development?

      server_count = deploy.all_servers.size
      server_msg =
        if server_count > 3
          "#{server_count} servers"
        else
          deploy.all_servers.join(", ")
        end

      msg = "#{deploy.auth_user.email} just began syncing #{build_link(deploy, false)}" \
            " to #{deploy.deploy_target.name.capitalize}"
      notify_room(SUPPORT_ROOM, msg, deploy.deploy_target.production?) if Rails.env.production? || Rails.env.test?

      msg = "#{deploy.deploy_target.name.capitalize}: #{deploy.auth_user.email} " \
            "just began syncing #{deploy.project_name.capitalize} to " \
            "#{build_link(deploy)} [#{server_msg}]"

      previous_deploy = deploy.deploy_target.previous_deploy(deploy)
      msg += "<br>GitHub Diff: <a href='#{deploy.project.diff_url(previous_deploy, deploy)}'>" \
             "#{build_link(previous_deploy, false)} ... #{build_link(deploy, false)}" \
             "</a>" if previous_deploy
      notify_room(ENG_ROOM, msg, deploy.deploy_target.production?)
    end

    def notify_deploy_complete(deploy)
      return if Rails.env.development?

      msg = "#{deploy.auth_user.email} just finished syncing #{build_link(deploy, false)} to " \
        "#{deploy.deploy_target.name.capitalize}"
      notify_room(SUPPORT_ROOM, msg, deploy.deploy_target.production?) if Rails.env.production? || Rails.env.test?

      msg = "#{deploy.deploy_target.name.capitalize}: #{deploy.auth_user.email} " \
            "just finished syncing #{deploy.project_name.capitalize} to #{build_link(deploy)}"
      notify_room(ENG_ROOM, msg, deploy.deploy_target.production?)
    end

    def notify_deploy_cancelled(deploy)
      msg = "#{deploy.deploy_target.name.capitalize}: #{deploy.auth_user.email} just " \
            "CANCELLED syncing #{deploy.project_name.capitalize} to #{build_link(deploy, false)}"
      notify_room(SUPPORT_ROOM, msg, deploy.deploy_target.production?) if Rails.env.production? || Rails.env.test?
      notify_room(ENG_ROOM, msg, deploy.deploy_target.production?)
    end

    def notify_deploy_failed_servers(failed_hosts)
      msg = "#{deploy.deploy_target.name.capitalize}: Unable to fully sync to the " \
            "following hosts: " + failed_hosts.sort.join(", ")
      notify_room(ENG_ROOM, msg, deploy.deploy_target.production?, "red")
    end

    def notify_untested_deploy(deploy)
      msg = "#{deploy.deploy_target.name.capitalize}: #{deploy.auth_user.email} just started " \
            "an UNTESTED deploy of #{deploy.project_name.capitalize} to #{build_link(deploy, false)}"
      notify_room(ENG_ROOM, msg, deploy.deploy_target.production?, "red")
    end

    def notify_room(room, msg, production, color = nil)
      hipchat_host = "hipchat.dev.pardot.com"
      uri = URI.parse("https://#{hipchat_host}/v1/rooms/message")

      unless %w[yellow red green purple gray].include?(color)
        color = (production ? "purple" : "gray")
      end

      body = {
        format: "json",
        auth_token: ENV["HIPCHAT_AUTH_TOKEN"],
        room_id: room,
        from: "Canoe",
        color: color,
        message_format: "html",
        message: msg
      }
      # NOTE: from name has to be between 1-15 characters

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(body)

      if Rails.env.production? || ENV["CANOE_HIPCHAT_ENABLED"].to_s == "true"
        http.request(request)
      end

      Instrumentation.log(at: "hipchat", room: room, msg: msg)
    end

    def build_link(deploy, link = true)
      if deploy.branch == "master"
        build_txt = "build#{deploy.build_number}"
      else
        build_txt = "#{deploy.branch} build#{deploy.build_number}"
      end
      commit_link = deploy.project.commit_url(deploy)
      link ? "<a href='#{commit_link}'>#{build_txt}</a>" : build_txt
    end
  end
end
