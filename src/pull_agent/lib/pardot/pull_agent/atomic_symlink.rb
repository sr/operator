require "securerandom"

module Pardot
  module PullAgent
    class AtomicSymlink
      def self.create!(source, target)
        source = source.to_s
        target = target.to_s

        retries = 0
        begin
          tmp_suffix = SecureRandom.hex(8)
          FileUtils.ln_s(source, target + tmp_suffix)
        rescue Errno::EEXIST
          retries += 1
          if retries >= 10
            raise "unable to link '#{source}' to '#{target}'"
          else
            retry
          end
        end

        FileUtils.rm_rf(target) if File.directory?(target)
        File.rename(target + tmp_suffix, target)
      end
    end
  end
end
