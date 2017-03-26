describe "performing restart tasks" do
  let(:build_number) { 1234 }
  let(:artifact_url) { "https://artifactory.dev.pardot.com/artifactory/api/storage/build1234.tar.gz" }
  let(:sha) { "bcd234" }

  let(:tempdir) { Dir.mktmpdir("pull-agent") }

  after { FileUtils.rm_rf(tempdir) }

  before do
    ENV["RELEASE_DIRECTORY"] = tempdir

    stub_request(:get, "http://canoe.test/api/targets/test/deploys/latest?repo_name=pardot&server=#{PullAgent::ShellHelper.hostname}")
      .to_return(body: %({"id":445,"branch":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{PullAgent::ShellHelper.hostname}":{"stage":"deployed","action":"restart"}}}))

    bootstrap_repo_path(tempdir)
    version = PullAgent::BuildVersion.new(build_number, sha, artifact_url)
    version.save_to_directory(File.join(tempdir, "current"))
  end

  after do
    ENV.delete("RELEASE_DIRECTORY")
  end

  it "performs restart task" do
    canoe_request = stub_request(:put, "http://canoe.test/api/targets/test/deploys/445/results/#{PullAgent::ShellHelper.hostname}")
      .to_return(status: 200)

    # Restarting redisjobs
    stub_request(:get, "http://127.0.0.1:8383/v1/service/redis-job-1")
      .to_return(body: %([{"payload":{"role":"master"},"address":"redis.example","port":1234}]))
    expect(PullAgent::Redis).to receive(:bounce_redis_jobs)
      .with("redis.example", 1234)
    stub_request(:get, /http:\/\/127.0.0.1:8383\/v1\/service\/redis-job-[2-9]/)
      .to_return(body: %([]))

    # Restarting autojobs
    stub_request(:get, "http://127.0.0.1:8383/v1/service/redis-rules-cache-1")
      .to_return(body: %([{"payload":{"role":"master"},"address":"redis.example","port":1234}]))
    %w[PerAccountAutomationWorker PerAccountAutomationWorker-timed automationRelatedObjectWorkers previewWorkers].each do |worker_type|
      expect(PullAgent::Redis).to receive(:bounce_workers)
        .with(worker_type, ["redis.example:1234"])
    end
    stub_request(:get, /http:\/\/127.0.0.1:8383\/v1\/service\/redis-rules-cache-[2-9]/)
      .to_return(body: %([]))

    cli = PullAgent::CLI.new(%w[test pardot])
    _output = capturing_stdout { cli.checkin }

    expect(canoe_request).to have_been_made
  end
end
