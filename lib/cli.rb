require 'console'
require 'shell_helper'

class CLI
  attr_accessor :options, :arguments

  def initialize(args=ARGV)
    @options = default_options
    @arguments = args
  end

  def default_options
    { environment: :production,
      lock_env: false,
      only_lock_env: false,
      unlock_env: false,
      force_unlock: false,
      canoe_deploy_id: "",
      no_confirmation: false,
      payload: "pardot",
      requested_type: :tag,
    }
  end

  def setup
    parse_arguments
    environment.payload = @options[:payload]
    environment.user = @options[:user_name]
  end

  def start!
    return if run_as_root?

    conductor = environment.conductor
    conductor.dont_ask! if @options[:no_confirmations]
    environment.deploy_options[:buildnum] = @options[:requested_value]
    environment.deploy_options[:artifact_url] = @options[:artifact_url]
    conductor.deploy!
  end

  def parse_arguments
    # make sure our environment is specified
    if @arguments.size.zero?
      Console.log("ERROR: Environment is required.\n", :red)
      print_help
    end

    @arguments.each_with_index do |arg, index|
      if %w[help --help -h].include?(arg.downcase)
        print_help
        return
      end

      # our environment MUST be the first argument
      if index == 0
        if valid_environment?(arg)
          @options[:environment] = arg.downcase.to_sym
          next # skip the rest of our scanning
        else
          Console.log("ERROR: Invalid environment specified.\n", :red)
          print_help
          return
        end
      end

      if arg.match(%r{^tag}i)
        @options[:requested_type] = :tag
        @options[:requested_value] = arg.split("=").last
      elsif arg.match(%r{--no-confirmations}i)
        @options[:no_confirmations] = true
      elsif arg.match(%r{--artifact-url}i)
        @options[:artifact_url] = arg.split("=", 2).last
      elsif arg.match(%r{--user}i)
        @options[:user_name] = arg.split("=").last
      # --------------------------------------
      else
        # second param can be the payload to sync...
        if index == 1 && environment.valid_payload?(arg.downcase)
          @options[:payload] = arg.downcase
        else
          Console.log("ERROR: Unknown argument '#{arg}'.\n\n", :red)
          print_help
          return
        end
      end
    end # args.each
  end # parse_arguments

  def print_help
    usage = /Usage\n=====\n+(.*?)\n\n\n/m.match(IO.read(File.join(File.dirname(File.dirname(__FILE__)), 'README.md')))
    if usage.nil?
      Console.log("Please refer to the Readme for usage information")
    else
      Console.log(usage[1])
    end
    exit
  end


  def valid_environment?(env)
    env_sym = env.to_s.downcase.to_sym
    valid_environments.include?(env_sym)
  end

  def valid_environments
    # TODO: should we have long and short names?
    [:production, :staging, :test, :dev, :engagement]
  end

  def environment
    @_environment ||= \
      begin
        env_require = "environment_" + @options[:environment].to_s
        env_class = "Environment" + @options[:environment].to_s.split("_").map(&:capitalize).join
        require env_require
        Object.const_get(env_class).new
      end
  end

  def run_as_root?
    if ShellHelper.user_is_root?(@options[:user_name])
      Console.log("Please do not run this with sudo or as root. kthxbye!", :yellow)
      true
    else
      false
    end
  end

  def check_version
    version = nil
    if (File.exist?(environment.payload.tag_file))
      File.open(environment.payload.tag_file).each do |line|
        if (line =~ /build\d+/)
          version = Regexp.last_match[0]
        end
      end
    end
    version
  end
end
