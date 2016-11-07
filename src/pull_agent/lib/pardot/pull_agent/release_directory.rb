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
      def initialize(parent_directory, current_symlink: "current")
        @parent_directory = Pathname.new(parent_directory)
        @current_symlink = current_symlink

        @a_directory = @parent_directory.join("releases/A")
        @b_directory = @parent_directory.join("releases/B")
      end

      def current_symlink
        @parent_directory.join(@current_symlink)
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
        AtomicSymlink.create!(standby_directory, current_symlink)
      end

      def to_s
        @parent_directory.to_s
      end

      def to_str
        @parent_directory.to_s
      end
    end
  end
end
