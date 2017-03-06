module TestHelpers
  module Fixtures
    EMPTY_TAR_GZ_CONTENTS = File.read(File.join(File.dirname(__FILE__), "..", "fixtures", "empty.tar.gz")).freeze
    HELLO_TAR_GZ_CONTENTS = File.read(File.join(File.dirname(__FILE__), "..", "fixtures", "hello.tar.gz")).freeze
    BUILD_VERSION_CONTENTS = File.read(File.join(File.dirname(__FILE__), "..", "fixtures", "build.version")).freeze

    def empty_tar_gz_contents
      EMPTY_TAR_GZ_CONTENTS
    end

    # This tarball contains one file 'hello.txt' with the contents 'hello world'
    def hello_tar_gz_contents
      HELLO_TAR_GZ_CONTENTS
    end

    def build_version_contents
      BUILD_VERSION_CONTENTS
    end

    def bootstrap_repo_path(tempdir)
      FileUtils.mkdir_p(File.join(tempdir, "releases", "A"))
      FileUtils.mkdir_p(File.join(tempdir, "releases", "B"))
      File.symlink(File.join(tempdir, "releases", "A"), File.join(tempdir, "current"))
    end
  end
end
