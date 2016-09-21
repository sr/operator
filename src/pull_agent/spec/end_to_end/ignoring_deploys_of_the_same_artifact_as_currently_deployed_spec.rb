describe "ignoring deploys of the same artifact as currently deployed" do
  let(:build_number) { 1234 }
  let(:sha) { "abc123" }
  let(:artifact_url) { "https://artifactory.dev.pardot.com/build1234.tar.gz" }
  let(:artifact_download_url) { "https://artifactory.dev.pardot.com/download/build1234.tar.gz" }
  let(:tempdir) { Dir.mktmpdir("pull-agent") }

  after { FileUtils.rm_rf(tempdir) }

  before do
    stub_request(:get, "http://canoe.test/api/targets/test/deploys/latest?repo_name=pardot&server=#{Pardot::PullAgent::ShellHelper.hostname}")
      .to_return(body: %({"id":445,"branch":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{Pardot::PullAgent::ShellHelper.hostname}":{"stage":"pending","action":"deploy"}}}))

    bootstrap_repo_path(tempdir)
    current_version = Pardot::PullAgent::BuildVersion.new(build_number, sha, artifact_url)
    File.write(File.join(tempdir, "current", "build.version"), current_version.to_s)
  end

  it "exits immediately without changing anything" do
    stub_request(:put, /^http:\/\/canoe.test\//)

    cli = Pardot::PullAgent::CLI.new(%w[test pardot])
    cli.parse_arguments!
    cli.environment.payload.options[:repo_path] = tempdir

    output = capturing_stdout do
      cli.checkin
    end
    expect(output).to match(/We are up to date/)
  end

  it "notifies Canoe that the deployment is completed" do
    request = stub_request(:put, "http://canoe.test/api/targets/test/deploys/445/results/#{Pardot::PullAgent::ShellHelper.hostname}")
              .with(body: { action: "deploy", success: "true" })
              .to_return(status: 200)

    cli = Pardot::PullAgent::CLI.new(%w[test pardot])
    cli.parse_arguments!
    cli.environment.payload.options[:repo_path] = tempdir

    capturing_stdout do
      cli.checkin
    end

    expect(request).to have_been_made
  end
end
