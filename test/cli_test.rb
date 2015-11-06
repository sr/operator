require "test_helper"
require "cli"

describe CLI do
  before do
    Console.silence!
    CLI.any_instance.stubs(:exit)
  end

  it "prints help and exits if --help is passed as an argument" do
    cli = CLI.new(%w[--help])
    cli.expects(:exit)

    cli.parse_arguments!
  end

  describe "parsing arguments" do
    it "expects environment as first argument" do
      cli = CLI.new

      Console.stubs(:log)
      Console.expects(:log).with { |arg| arg.match(/Usage/) }
      cli.parse_arguments!
    end

    it "expects valid argument as first argument" do
      cli = CLI.new(%w[foo])

      Console.stubs(:log)
      Console.expects(:log).with { |arg| arg.match(/Invalid environment/) }
      cli.parse_arguments!
    end

    it "expects valid payload as second argument" do
      cli = CLI.new(%w[test bad])

      Console.stubs(:log)
      Console.expects(:log).with { |arg| arg.match(/Invalid payload specified/) }
      cli.parse_arguments!
    end

    it "prints an error on unknown arguments" do
      cli = CLI.new(%w[test pardot bogus])

      Console.stubs(:log)
      Console.expects(:log).with { |arg| arg.match(/Unknown argument: bogus/) }
      cli.parse_arguments!
    end

    it "parses payload as second argument" do
      cli = CLI.new(%w[test pithumbs])

      cli.parse_arguments!
      cli.options[:payload].must_equal("pithumbs")
    end
  end

  describe "environment" do
    it "should return production environment if requested" do
      cli = CLI.new(%w[prod pardot])

      cli.parse_arguments!
      cli.environment.class.must_equal(EnvironmentProduction)
    end

    it "should return development environment if requested" do
      cli = CLI.new(%w[dev pardot])

      cli.parse_arguments!
      cli.environment.class.must_equal(EnvironmentDev)
    end
  end

  describe "checkin" do
    before do
      @cli = CLI.new(%w[test pardot])
      @cli.parse_arguments!
      @env = @cli.environment
    end

    it "should ignore deploys marked complete" do
      build_number = 1234
      sha = "abc123"
      artifact_url = "http://artifactory.example/build1234.tar.gz"
      stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
        .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{ShellHelper.hostname}":{"stage":"completed","action":null}}}))
      BuildVersion.stubs(:load).returns(BuildVersion.new(build_number,sha,artifact_url))
      Console.expects(:log).with("Nothing to do for this deploy: #{build_number}")
      @cli.checkin
    end

    it "should restart job servers" do
      build_number = 1234
      sha = "abc123"
      artifact_url = "http://artifactory.example/build1234.tar.gz"
      @env.conductor.stubs(:restart_jobs!)
      Canoe.stubs(:notify_server)
      stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
        .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{ShellHelper.hostname}":{"stage":"deployed","action":"restart"}}}))
      BuildVersion.stubs(:load).returns(BuildVersion.new(build_number,sha,artifact_url))
      Console.expects(:log).with("Restarted job servers")
      @cli.checkin
    end

    it "should handle redeploys of the same thing" do
      build_number = 1234
      sha = "abc123"
      artifact_url = "http://artifactory.example/build1234.tar.gz"
      Canoe.stubs(:notify_server)
      stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
        .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{ShellHelper.hostname}":{"stage":"initiated","action":"deploy"}}}))
      BuildVersion.stubs(:load).returns(BuildVersion.new(build_number,sha,artifact_url))
      Console.expects(:log).with("We are up to date: #{build_number}")
      @cli.checkin
    end

    it "should actually launch a deploy" do
      build_number = 1234
      sha = "abc123"
      artifact_url = "http://artifactory.example/build1234.tar.gz"
      @env.conductor.stubs(:deploy!)
      stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
        .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{ShellHelper.hostname}":{"stage":"initiated","action":"deploy"}}}))
      current_build_version = BuildVersion.new(build_number-1,sha,"http://example/build123.tar")
      BuildVersion.stubs(:load).returns(current_build_version)
      Console.expects(:log).with("Current build: #{current_build_version}")
      Console.expects(:log).with("Requested deploy: #{build_number}")
      @cli.checkin
    end

    it "should not do anything if it doesn't apploy to the server" do
      build_number = 1234
      sha = "abc123"
      artifact_url = "http://artifactory.example/build1234.tar.gz"
      stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
        .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"localhost":{"stage":"initiated","action":"deploy"}}}))
      BuildVersion.stubs(:load).returns(BuildVersion.new(build_number,sha,artifact_url))
      Console.expects(:log).with("The latest deploy does not apply to this server: #{build_number}", :green)
      @cli.checkin
    end
  end
end
