describe "ignoring deploys marked completed" do
  let(:build_number) { 1234 }
  let(:sha) { "abc123" }
  let(:artifact_url) { "https://artifactory.dev.pardot.com/build1234.tar.gz" }
  let(:artifact_download_url) { "https://artifactory.dev.pardot.com/download/build1234.tar.gz" }
  let(:tempdir) { Dir.mktmpdir("pull-agent") }

  after { FileUtils.rm_rf(tempdir) }

  before do
    stub_request(:get, "http://canoe.test/api/targets/test/deploys/latest?repo_name=pardot&server=#{Pardot::PullAgent::ShellHelper.hostname}")
      .to_return(body: %({"id":445,"branch":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{Pardot::PullAgent::ShellHelper.hostname}":{"stage":"completed","action":null}}}))
  end

  it "exits immediately without changing anything" do
    cli = Pardot::PullAgent::CLI.new(%w[test pardot])

    output = capturing_stdout { cli.checkin }
    expect(output).to match(/Nothing to do for this deploy/)
  end
end
