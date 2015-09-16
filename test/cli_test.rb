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
end
