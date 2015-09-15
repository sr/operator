require_relative "test_helper.rb"
require "cli"
require "conductor"

describe CLI do
  before { Console.silence! }

  it "should intialize with default options" do
    cli = CLI.new
    cli.options.must_equal(cli.default_options)
  end

  it "should exit after printing the help" do
    cli = CLI.new
    cli.expects(:exit)
    cli.print_help
  end

  describe "parsing arguments" do
    it "should print help with different help options" do
      cli = CLI.new(%w[--help])
      cli.expects(:print_help)
      cli.parse_arguments
    end

    it "expects environment as first argument" do
      cli = CLI.new
      cli.expects(:print_help)
      Console.expects(:log).with { |arg| arg.match(/Environment is required/) }
      cli.parse_arguments
    end

    it "expects valid argument as first argument" do
      cli = CLI.new(%w[foo])
      cli.expects(:print_help)
      Console.expects(:log).with { |arg| arg.match(/Invalid environment/) }
      cli.parse_arguments
    end

    it "handles unknown arguments" do
      cli = CLI.new(%w[test bad])
      cli.expects(:print_help)
      Console.expects(:log).with { |arg| arg.match(/Unknown argument/) }
      cli.parse_arguments
    end

    it "parses payload as second argument" do
      cli = CLI.new(%w[test pithumbs])
      cli.parse_arguments
      cli.options[:payload].must_equal("pithumbs")
    end

    it "defaults payload to pardot" do
      cli = CLI.new(%w[test])
      cli.parse_arguments
      cli.options[:payload].must_equal("pardot")
    end

    it "parses tag and value" do
      cli = CLI.new(%w[test tag=build1234])
      mock_conductor(cli) do |conductor|
        conductor.expects(:deploy!)
      end
      cli.setup
      cli.start! # calls parse_arguments
    end

    it "handles --no-confirmations" do
      cli = CLI.new(%w[test --no-confirmations])
      mock_conductor(cli) do |conductor|
        conductor.expects(:dont_ask!)
        conductor.expects(:deploy!)
      end
      cli.setup
      cli.start! # calls parse_arguments
    end

  end

  it "warns if run as root" do
    # fake it by passing root in
    cli = CLI.new(%w[test --user=root])
    mock_conductor(cli) do |conductor|
      conductor.expects(:deploy!).never
    end
    Console.expects(:log).with { |arg| arg.match(/do not run this with sudo/) }
    cli.setup
    cli.start!
  end

  describe "environment" do
    it "should return production environment if requested" do
      cli = CLI.new(%w[production])
      cli.parse_arguments
      # this will spew warnings b/c of constant redefines
      cli.environment.class.must_equal(EnvironmentProduction)
    end

    it "should return development environment if requested" do
      cli = CLI.new(%w[dev])
      cli.parse_arguments
      # this will spew warnings b/c of constant redefines
      cli.environment.class.must_equal(EnvironmentDev)
    end
  end

  def mock_conductor(cli, &block)
    env_mock = mock
    env_mock.stubs(:payload=)
    env_mock.stubs(:user=)
    env_mock.stubs(:deploy_options).returns({})
    conductor = Conductor.new(env_mock)
    yield(conductor) if block_given?
    env_mock.stubs(:conductor).returns(conductor)
    cli.stubs(:environment).returns(env_mock)
  end

end
