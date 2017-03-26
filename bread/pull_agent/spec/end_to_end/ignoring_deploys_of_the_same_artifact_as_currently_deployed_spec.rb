describe "ignoring deploys of the same artifact as currently deployed" do
  let(:build_number) { 1234 }
  let(:sha) { "abc123" }
  let(:artifact_url) { "https://artifactory.dev.pardot.com/build1234.tar.gz" }
  let(:artifact_download_url) { "https://artifactory.dev.pardot.com/download/build1234.tar.gz" }
  let(:tempdir) { Dir.mktmpdir("pull-agent") }

  before do
    ENV["RELEASE_DIRECTORY"] = tempdir

    stub_request(:get, "http://canoe.test/api/targets/test/deploys/latest?repo_name=pardot&server=#{PullAgent::ShellHelper.hostname}")
      .to_return(body: %({"id":445,"branch":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{PullAgent::ShellHelper.hostname}":{"stage":"pending","action":"deploy"}}}))

    bootstrap_repo_path(tempdir)
    current_version = PullAgent::BuildVersion.new(build_number, sha, artifact_url)
    File.write(File.join(tempdir, "current", "build.version"), current_version.to_s)
  end

  after do
    ENV.delete("RELEASE_DIRECTORY")
  end

  it "exits immediately without changing anything" do
    stub_request(:put, /^http:\/\/canoe.test\//)

    cli = PullAgent::CLI.new(%w[test pardot])
    output = capturing_stdout { cli.checkin }
    expect(output).to match(/Requested deploy is already present.*Skipping fetch step/)
  end

  it "notifies Canoe that the deployment is completed" do
    request = stub_request(:put, "http://canoe.test/api/targets/test/deploys/445/results/#{PullAgent::ShellHelper.hostname}")
      .with(body: { action: "deploy", success: "true" })
      .to_return(status: 200)

    cli = PullAgent::CLI.new(%w[test pardot])
    _output = capturing_stdout { cli.checkin }

    expect(request).to have_been_made
  end
end
