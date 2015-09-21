require "uri"
require "net/http"

class Hipchat
  SUPPORT_ROOM = "support"
  ENG_ROOM     = "engineering"

  class << self
    def notify_deploy_start(deploy)
      previous_deploy = deploy.deploy_target.previous_deploy(deploy)  
      server_count = deploy.all_sync_servers.size
      if server_count > 3
        server_msg = "#{server_count} servers"
      else
        server_msg = deploy.all_sync_servers.join(', ')
      end
  
      # tell support
      msg = "#{deploy.auth_user.email} just began syncing #{build_txt}" + \
            " to #{deploy.deploy_target.name}"
      notify_room(SUPPORT_ROOM, msg)
  
      # tell engineering
      # NOTE: parbot currently listens for this format to work with !lastrelease, etc
      msg = "#{deploy.deploy_target.name}: #{deploy.auth_user.email} just began " + \
            "syncing #{deploy.repo_name.capitalize} to #{build_link(deploy)} " + \
            "[#{server_msg}]"
      msg += "<br>GitHub Diff: #{deploy.repo.diff_url(deploy, previous_deploy)}" if previous_deploy
      notify_room(ENG_ROOM, msg)
    end
  
    def notify_deploy_complete(deploy)
      # tell support
      msg = "#{deploy.auth_user.email} just finished syncing #{build_txt} to " + \
            "#{deploy.deploy_target.name}"
      notify_room(SUPPORT_ROOM, msg) if Rails.env.production?
  
      # tell engineering
      msg = "#{deploy.deploy_target.name}: #{deploy.auth_user.email} just finished " + \
            "syncing #{deploy.repo_name.capitalize} to #{build_link(deploy)}"
      notify_room(ENG_ROOM, msg)
    end
  
    def notify_deploy_cancelled(deploy)
      msg = "#{deploy.deploy_target.name}: #{deploy.auth_user.email} just CANCELLED " + \
            "syncing #{deploy.repo_name.capitalize} to #{build_link(deploy)}"
      notify_room(SUPPORT_ROOM, msg) if Rails.env.production?
      notify_room(ENG_ROOM, msg)
    end
  
    def notify_deploy_failed_servers(failed_hosts)
      msg = "#{deploy.deploy_target.name}: Unable to fully sync to the following hosts: " + \
            failed_hosts.sort.join(", ")
      notify_room(ENG_ROOM, msg, "red")
    end
  
    def notify_room(room, msg, color=nil)
      hipchat_host = "hipchat.dev.pardot.com"
      uri = URI.parse("https://#{hipchat_host}/v1/rooms/message")
  
      unless %w[yellow red green purple gray].include?(color)
        color = (Rails.env.production? ? "purple" : "gray")
      end
  
      body = {
        :format         => "json",
        :auth_token     => "62b38be68d7593e4da865dcff0c2db",
        :room_id        => room,
        :from           => "#{deploy.deploy_target.name} Update",
        :color          => color,
        :message_format => "html",
        :message        => msg,
      }
      # NOTE: from name has to be between 1-15 characters
  
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
  
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(body)
  
      http.request(request)
      Console.log("HIPCHAT: [#{room}] #{msg}")
    end
  
    def build_link(deploy)
      if deploy.what_details == "master"
        build_txt = "build#{deploy.build_number}"
      else
        build_txt = "#{deploy.what_details} build#{deploy.build_number}"
      end
      commit_link = deploy.repo.commit_url(deploy.sha)
      "<a href='#{commit_link}'>#{build_txt}</a>"
    end
  end
end
