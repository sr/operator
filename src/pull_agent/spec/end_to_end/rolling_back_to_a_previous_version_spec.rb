describe "rollback back to a previous version" do
  let(:first_build_number) { 1111 }
  let(:first_sha) { "abc123" }
  let(:first_artifact_url) { "https://artifactory.dev.pardot.com/artifactory/api/storage/build1111.tar.gz" }

  let(:current_build_number) { 1234 }
  let(:current_sha) { "bcd234" }
  let(:current_artifact_url) { "https://artifactory.dev.pardot.com/artifactory/api/storage/build1234.tar.gz" }

  let(:tempdir) { Dir.mktmpdir("pull-agent") }

  after { FileUtils.rm_rf(tempdir) }

  # The second build is deployed, and we're stubbing out a revert deploy back to the first build.
  before do
    ENV["RELEASE_DIRECTORY"] = tempdir

    stub_request(:get, "http://canoe.test/api/targets/test/deploys/latest?repo_name=pardot&server=#{PullAgent::ShellHelper.hostname}")
      .to_return(body: %({"id":445,"branch":"master","artifact_url":"#{first_artifact_url}","build_number":#{first_build_number},"created_at":"2015-12-20T14:26:29-05:00", "servers":{"#{PullAgent::ShellHelper.hostname}":{"stage":"pending","action":"deploy"}}}))

    bootstrap_repo_path(tempdir)

    first_version = PullAgent::BuildVersion.new(first_build_number, first_sha, first_artifact_url)
    FileUtils.mkdir_p(File.join(tempdir, "releases", "B"))
    File.write(
      File.join(tempdir, "releases", "B", "build.version"),
      first_version.to_s
    )

    current_version = PullAgent::BuildVersion.new(current_build_number, current_sha, current_artifact_url)
    File.write(File.join(tempdir, "current", "build.version"), current_version.to_s)
  end

  after do
    ENV.delete("RELEASE_DIRECTORY")
  end

  it "rapidly changes the symlink back to the previous version" do
    canoe_request = stub_request(:put, "http://canoe.test/api/targets/test/deploys/445/results/#{PullAgent::ShellHelper.hostname}")
      .to_return(status: 200)

    cli = PullAgent::CLI.new(%w[test pardot])

    expect(File.readlink(File.join(tempdir, "current"))).to match(/releases\/A$/)
    _output = capturing_stdout { cli.checkin }

    expect(canoe_request).to have_been_made
    expect(File.readlink(File.join(tempdir, "current"))).to match(/releases\/B$/)
  end
end
