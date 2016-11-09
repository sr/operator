require "fileutils"

module PullAgent
  class DirectorySynchronizer
    SynchronizationFailedError = Class.new(StandardError)

    def initialize(source, destination)
      @source = source
      @destination = destination
    end

    def synchronize
      FileUtils.mkdir_p(@destination.to_s)
      output = IO.popen(["rsync", "--recursive", "--checksum", "--links", "--perms", "--verbose", "--delete", @source.to_s + "/", @destination.to_s], &:read)

      raise SynchronizationFailedError, "synchronization failed: #{output}" unless $?.success?
      true
    end
  end
end
