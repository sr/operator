require "spec_helper"

describe Pardot::PullAgent::CLI do
  describe "parsing arguments" do
    it "expects environment as first argument" do
      cli = Pardot::PullAgent::CLI.new
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to include("Usage")
    end

    it "prints help and exits if --help is passed as an argument" do
      cli = Pardot::PullAgent::CLI.new(%w[--help])
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to include("Usage")
    end

    it "expects valid argument as first argument" do
      cli = Pardot::PullAgent::CLI.new(%w[foo])
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to match(/Invalid environment/)
    end

    it "expects valid payload as second argument" do
      cli = Pardot::PullAgent::CLI.new(%w[test bad])
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to match(/Invalid payload specified/)
    end

    it "prints an error on unknown arguments" do
      cli = Pardot::PullAgent::CLI.new(%w[test pardot bogus])
      output = capturing_stdout do
        cli.parse_arguments!
      end

      expect(output).to match(/Unknown argument: bogus/)
    end

    it "parses payload as second argument" do
      cli = Pardot::PullAgent::CLI.new(%w[test pithumbs])
      capturing_stdout do
        cli.parse_arguments!
      end

      expect(cli.environment.payload.id).to eq(:pithumbs)
    end
  end

  describe "environment" do
    it "should return production environment if requested" do
      cli = Pardot::PullAgent::CLI.new(%w[production pardot])
      cli.parse_arguments!

      expect(cli.environment).to be_instance_of(Pardot::PullAgent::Environments::Production)
    end

    it "should return development environment if requested" do
      cli = Pardot::PullAgent::CLI.new(%w[dev pardot])
      cli.parse_arguments!

      expect(cli.environment).to be_instance_of(Pardot::PullAgent::Environments::Dev)
    end
  end
end