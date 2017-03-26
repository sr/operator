module Notifiers
  # Notifier to create hipchat messages.
  class Chat
    DIREWOLF_DEPLOY_REGEX = /\Adirewolf-[A-Za-z0-9\-]{10,12}(-(renamed|redux|new))?\z/
    PR_APP_REGEX = /-pr-\d*/

    def client
      @client ||= Clients::Heimdall.new
    end

    def emergency_override(multipass)
      payload = {
        type: "override",
        actor: multipass.emergency_approver,
        repo: override_name(multipass),
        link: override_link(multipass)
      }
      client.notify(multipass.repository, payload)
    end

    def deploy(event)
      return if ignore? event.app_name
      client.notify(event.repository, event.to_chat_hash)
    end

    def override_name(multipass)
      multipass.repository_name || "a multipass"
    end

    def override_link(multipass)
      if multipass.persisted?
        multipass.permalink
      else
        multipass.reference_url
      end
    end

    def ignore?(name)
      direwolf_deploy?(name) || pr_app?(name)
    end

    def direwolf_deploy?(name)
      return false if name == "direwolf-production"

      if name =~ DIREWOLF_DEPLOY_REGEX
        true
      else
        false
      end
    end

    def pr_app?(name)
      if name =~ PR_APP_REGEX
        true
      else
        false
      end
    end
  end
end
