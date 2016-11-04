require "pathname"
require "fileutils"

module Pardot
  module PullAgent
    # ReleaseDirectory provides functionality around deploying to and atomically switching to a new release via symlinks.
    #
    # ReleaseDirectory expects a setup like:
    #
    # /path/to/release/directory
    # |- current -> releases/{A,B}
    # |- releases
    #   |- A
    #   |- B
    class ReleaseDirectory
      def initialize(parent_directory)
        @parent_directory = Pathname.new(parent_directory)

        @a_directory = @parent_directory.join("releases/A")
        @b_directory = @parent_directory.join("releases/B")
      end

      def current_symlink
        @parent_directory.join("current")
      end

      def live_directory
        current_symlink.realpath
      end

      def standby_directory
        {
          @a_directory => @b_directory,
          @b_directory => @a_directory
        }.fetch(live_directory, @b_directory)
      end

      def make_standby_directory_live
        temp_current_symlink = @parent_directory.join("current_temp")
        FileUtils.ln_sf(standby_directory, temp_current_symlink)
        File.rename(temp_current_symlink, current_symlink)
      end
    end
  end
end
