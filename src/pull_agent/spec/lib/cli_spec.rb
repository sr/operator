require "spec_helper"

describe Pardot::PullAgent::CLI do
  describe "parsing arguments" do
    it "expects environment as first argument" do
      expect { Pardot::PullAgent::CLI.new([]) }.to raise_error(ArgumentError)
    end

    it "prints help and exits if --help is passed as an argument" do
      expect { Pardot::PullAgent::CLI.new(%w[--help]) }.to raise_error(ArgumentError)
    end

    it "prints an error on unknown arguments" do
      expect { Pardot::PullAgent::CLI.new(%w[test pardot bogus]) }.to raise_error(ArgumentError)
    end
  end

  it "parses environment as its first argument" do
    cli = Pardot::PullAgent::CLI.new(%w[production pardot])
    expect(cli.environment).to eq("production")
  end

  it "parses project as its second argument" do
    cli = Pardot::PullAgent::CLI.new(%w[test pithumbs])
    expect(cli.project).to eq("pithumbs")
  end
end
