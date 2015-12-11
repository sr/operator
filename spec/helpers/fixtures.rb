module TestHelpers
  module Fixtures
    EMPTY_TAR_GZ_CONTENTS = File.read(File.join(File.dirname(__FILE__), "..", "fixtures", "empty.tar.gz")).freeze

    def empty_tar_gz_contents
      EMPTY_TAR_GZ_CONTENTS
    end
  end
end
