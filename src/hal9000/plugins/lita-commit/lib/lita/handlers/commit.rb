module Lita
  module Handlers
    class Commit < Handler
      # config: hal9000's "home room"
      config :status_room, default: "1_ops@conf.btf.hipchat.com"

      route /^commit(?:\s+(?<project>[a-z0-9\-]+))?\s+(?<sha>[a-f0-9]+)$/i, :commit, command: true, help: {
        "commit (project)? <commit sha>" => "Responds with the commit url for any repo, defaults to pardot"
      }

      route /^diff\s+(?<sha1>[^\s]+)(?:\s+(?<sha2>[^\s]+))?$/i, :diff, command: true, help: {
        "diff <sha1> <sha2>" => "Responds with the compare url for the Pardot repo"
      }

      def initialize(robot)
        super
        @status_room = ::Lita::Source.new(room: config.status_room)
      end

      on(:connected) do
        robot.join(config.status_room)
      end

      def commit(response)
        sha = response.match_data["sha"]
        project = response.match_data["project"] || "pardot"

        # TODO: figure out a way to post html using hipchat room notification
        # msg = "Commit: #{project} - #{sha}"
        url = "https://git.dev.pardot.com/Pardot/" + project + "/commit/" + sha
        # html = "<a href=\"#{url}\">#{msg}</a>"

        robot.send_message(@status_room, url)
      end

      def diff(response)
        sha2 = response.match_data["sha2"] || nil
        diff = response.match_data["sha1"].tr("/", ";")
        diff += sha2 ? "..." + sha2.tr("/", ";") : ""

        # msg = "Diff: #{diff}"
        url = "https://git.dev.pardot.com/Pardot/pardot/compare/" + diff + "?w=1"
        # html = "<a href=\"#{url}\">#{msg}</a>"

        robot.send_message(@status_room, url)
      end

      Lita.register_handler(self)
    end
  end
end
