require "strategies"
require "environments"
require "deploy"

describe Strategies::Fetch::Artifactory do
  let(:tempdir) { Dir.mktmpdir("pull-agent") }
  let(:environment) {
    Environments.build(:test).tap { |e|
      e.payload = "pardot"
      e.payload.options[:repo_path] = tempdir
    }
  }

  let!(:strategy) { Strategies.build(:fetch, :artifactory, environment) }

  after { FileUtils.rm_rf(tempdir) }

  it "should use Artifactory to check validity of build" do
    artifact = double(properties: {"gitSha" => "abc123"})

    allow(Artifactory::Resource::Artifact).to receive(:from_url)
      .with("https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.tar.gz")
      .and_return(artifact)

    deploy = Deploy.from_hash("artifact_url" => "https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.tar.gz")
    expect(strategy.valid?(deploy)).to be_truthy
  end

  it "is not valid if gitSha property is not present" do
    artifact = double(properties: {})

    allow(Artifactory::Resource::Artifact).to receive(:from_url)
      .with("https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.tar.gz")
      .and_return(artifact)

    deploy = Deploy.from_hash("artifact_url" => "https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.tar.gz")
    expect(strategy.valid?(deploy)).to be_falsey
  end

  it "should use Artifactory to pull build" do
    local_artifact = File.join(environment.payload.artifacts_path, "WFS-153.tar.gz")

    stub_request(:get, "https://artifactory.dev.pardot.com/artifactory/pd-canoe/WFST/WFS/WFS-153.tar.gz")
      .to_return(
        status: 200,
        body: empty_tar_gz_contents,
        headers: {"Content-Type" => "application/x-gzip"}
      )

    artifact = double(download_uri: "https://artifactory.dev.pardot.com/artifactory/pd-canoe/WFST/WFS/WFS-153.tar.gz")
    allow(Artifactory::Resource::Artifact).to receive(:from_url)
      .with("https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.tar.gz")
      .and_return(artifact)

    deploy = Deploy.from_hash("artifact_url" => "https://artifactory.dev.pardot.com/artifactory/api/storage/pd-canoe/WFST/WFS/WFS-153.tar.gz")
    filename = strategy.fetch(deploy)
    expect(filename).to eq(local_artifact)
    expect(File.read(filename)).to eq(empty_tar_gz_contents)
  end

  it "should be type artifactory" do
    expect(strategy.type).to eq(:artifactory)
  end
end
