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

      command = ["rsync", "--recursive", "--checksum", "--links", "--perms", "--verbose", "--delete", @source.to_s + "/", @destination.to_s]
      Logger.log(:info, "Synchronizing directory: #{command.inspect}")

      output = IO.popen(command, &:read)
      raise SynchronizationFailedError, "synchronization failed: #{output}" unless $?.success?
      true
    end
  end
end
