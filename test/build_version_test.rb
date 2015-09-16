require "test_helper"
require "build_version"
require "tempfile"

describe BuildVersion do
  it "loads a build version file from disk" do
    Tempfile.create("build.version") do |tmpfile|
      tmpfile.write("build1234\nbfa9aac\nhttps://artifactory.example/build1234.tar.gz\n")
      tmpfile.flush

      build_version = BuildVersion.load(tmpfile.path)
      build_version.build_number.must_equal 1234
      build_version.sha.must_equal "bfa9aac"
      build_version.artifact_url.must_equal "https://artifactory.example/build1234.tar.gz"
    end
  end
end
