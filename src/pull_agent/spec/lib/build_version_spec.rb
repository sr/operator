require "spec_helper"

describe PullAgent::BuildVersion do
  it "loads a build version file from disk" do
    Tempfile.open("build.version") do |tmpfile|
      tmpfile.write("build1234\nbfa9aac\nhttps://artifactory.example/build1234.tar.gz\n")
      tmpfile.flush

      build_version = PullAgent::BuildVersion.load(tmpfile.path)
      expect(build_version.build_number).to eq(1234)
      expect(build_version.sha).to eq("bfa9aac")
      expect(build_version.artifact_url).to eq("https://artifactory.example/build1234.tar.gz")
    end
  end

  it "saves a build.version file to disk" do
    v = PullAgent::BuildVersion.new(1234, "bfa9aac", "https://artifactory.example/build1234.tar.gz")
    Tempfile.open("build.version") do |tmpfile|
      v.save_to_file(tmpfile)
      tmpfile.flush
      expect(tmpfile.read).to eq(build_version_contents)
    end
  end
end
