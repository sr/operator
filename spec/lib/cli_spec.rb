require "cli"

describe CLI do
  describe "parsing arguments" do
    it "expects environment as first argument" do
      cli = CLI.new
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to include("Usage")
    end

    it "prints help and exits if --help is passed as an argument" do
      cli = CLI.new(%w[--help])
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to include("Usage")
    end

    it "expects valid argument as first argument" do
      cli = CLI.new(%w[foo])
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to match(/Invalid environment/)
    end

    it "expects valid payload as second argument" do
      cli = CLI.new(%w[test bad])
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to match(/Invalid payload specified/)
    end

    it "prints an error on unknown arguments" do
      cli = CLI.new(%w[test pardot bogus])
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to match(/Unknown argument: bogus/)
    end

    it "parses payload as second argument" do
      cli = CLI.new(%w[test pithumbs])
      capturing_stdout do
        cli.parse_arguments!
      end

      expect(cli.environment.payload.id).to eq(:pithumbs)
    end
  end

  describe "environment" do
    it "should return production environment if requested" do
      cli = CLI.new(%w[production pardot])
      cli.parse_arguments!

      expect(cli.environment).to be_instance_of(Environments::Production)
    end

    it "should return development environment if requested" do
      cli = CLI.new(%w[dev pardot])
      cli.parse_arguments!

      expect(cli.environment).to be_instance_of(Environments::Dev)
    end
  end

  # TODO: Move these to be more integration-y tests
  # describe "checkin" do
  #   before do
  #     @cli = CLI.new(%w[test pardot])
  #     @cli.parse_arguments!
  #     @env = @cli.environment
  #   end

  #   it "should ignore deploys marked complete" do
  #     build_number = 1234
  #     sha = "abc123"
  #     artifact_url = "http://artifactory.example/build1234.tar.gz"
  #     stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
  #       .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{ShellHelper.hostname}":{"stage":"completed","action":null}}}))
  #     BuildVersion.stubs(:load).returns(BuildVersion.new(build_number,sha,artifact_url))
  #     Console.expects(:log).with("Nothing to do for this deploy: #{build_number}")
  #     @cli.checkin
  #   end

  #   it "should execute restart tasks" do
  #     build_number = 1234
  #     sha = "abc123"
  #     artifact_url = "http://artifactory.example/build1234.tar.gz"
  #     @env.conductor.stubs(:restart_jobs!)
  #     Canoe.stubs(:notify_server)
  #     stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
  #       .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{ShellHelper.hostname}":{"stage":"deployed","action":"restart"}}}))
  #     BuildVersion.stubs(:load).returns(BuildVersion.new(build_number,sha,artifact_url))
  #     Console.expects(:log).with("Executing restart tasks")
  #     @cli.checkin
  #   end

  #   it "should handle redeploys of the same thing" do
  #     build_number = 1234
  #     sha = "abc123"
  #     artifact_url = "http://artifactory.example/build1234.tar.gz"
  #     Canoe.stubs(:notify_server)
  #     stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
  #       .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{ShellHelper.hostname}":{"stage":"initiated","action":"deploy"}}}))
  #     BuildVersion.stubs(:load).returns(BuildVersion.new(build_number,sha,artifact_url))
  #     Console.expects(:log).with("We are up to date: #{build_number}")
  #     @cli.checkin
  #   end

  #   it "should actually launch a deploy" do
  #     build_number = 1234
  #     sha = "abc123"
  #     artifact_url = "http://artifactory.example/build1234.tar.gz"
  #     @env.conductor.stubs(:deploy!)
  #     stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
  #       .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"#{ShellHelper.hostname}":{"stage":"initiated","action":"deploy"}}}))
  #     current_build_version = BuildVersion.new(build_number-1,sha,"http://example/build123.tar")
  #     BuildVersion.stubs(:load).returns(current_build_version)
  #     Console.expects(:log).with("Current build: #{current_build_version}")
  #     Console.expects(:log).with("Requested deploy: #{build_number}")
  #     @cli.checkin
  #   end

  #   it "should not do anything if it doesn't apploy to the server" do
  #     build_number = 1234
  #     sha = "abc123"
  #     artifact_url = "http://artifactory.example/build1234.tar.gz"
  #     stub_request(:get, "#{@env.canoe_url}/api/targets/#{@env.canoe_target}/deploys/latest?repo_name=pardot&server=#{ShellHelper.hostname}")
  #       .to_return(body: %({"id":445,"what":"branch","what_details":"master","artifact_url":"#{artifact_url}","build_number":#{build_number},"servers":{"localhost":{"stage":"initiated","action":"deploy"}}}))
  #     BuildVersion.stubs(:load).returns(BuildVersion.new(build_number,sha,artifact_url))
  #     Console.expects(:log).with("The latest deploy does not apply to this server: #{build_number}", :green)
  #     @cli.checkin
  #   end
  # end
end
