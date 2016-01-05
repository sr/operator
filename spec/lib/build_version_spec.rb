require "spec_helper"
require "build_version"
require "tempfile"

describe BuildVersion do
  it "loads a build version file from disk" do
    Tempfile.open("build.version") do |tmpfile|
      tmpfile.write("build1234\nbfa9aac\nhttps://artifactory.example/build1234.tar.gz\n")
      tmpfile.flush

      build_version = BuildVersion.load(tmpfile.path)
      expect(build_version.build_number).to eq(1234)
      expect(build_version.sha).to eq("bfa9aac")
      expect(build_version.artifact_url).to eq("https://artifactory.example/build1234.tar.gz")
    end
  end
end
