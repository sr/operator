require 'console'

class CLI
  attr_reader :options

  def initialize(args = ARGV)
    @options = default_options
    @arguments = args
  end

  def parse_arguments!
    @arguments.each_with_index do |arg, index|
      if %w[help --help -h].include?(arg.downcase)
        print_help
        return
      end

      if index == 0
        # our environment MUST be the first argument
        if valid_environment?(arg)
          @options[:environment] = arg.downcase.to_sym
          next
        else
          Console.log("ERROR: Invalid environment specified.\n", :red)

          print_help
          return
        end
      elsif index == 1
        # the payload (repository name) MUST be the second argument
        if environment.valid_payload?(arg.downcase)
          @options[:payload] = arg.downcase
        else
          Console.log("ERROR: Invalid payload specified.\n", :red)

          print_help
          return
        end
      else
        Console.log("ERROR: Unknown argument: #{arg}", :red)

        print_help
        return
      end
    end

    # environment and payload (repository name) are required
    if @arguments.size < 2
      print_help
      return
    end
  end

  def environment
    @_environment ||= \
      begin
        env_require = "environment_" + @options[:environment].to_s
        env_class = "Environment" + @options[:environment].to_s.split("_").map(&:capitalize).join
        require env_require
        Object.const_get(env_class).new.tap { |environment| environment.payload = @options[:payload] }
      end
  end

  def checkin
    current_build_version = BuildVersion.load(environment.payload.build_version_file)
    requested_deploy = Canoe.latest_deploy(environment)
    if requested_deploy.applies_to_this_server?
      if requested_deploy.action == "restart"
        Console.log("Executing restart tasks")
        environment.conductor.restart!(requested_deploy)
        Canoe.notify_server(environment, requested_deploy)
      elsif requested_deploy.action == "deploy"
        if current_build_version && current_build_version.instance_of_deploy?(requested_deploy)
          Console.log("We are up to date: #{requested_deploy.build_number}")
          Canoe.notify_server(environment, requested_deploy)
        else
          Console.log("Current build: #{current_build_version || "<< None >>"}")
          Console.log("Requested deploy: #{requested_deploy.build_number}")
          environment.conductor.deploy!(requested_deploy)
        end
      else
        Console.log("Nothing to do for this deploy: #{requested_deploy.build_number}")
      end
    else
      Console.log("The latest deploy does not apply to this server: #{requested_deploy.build_number}", :green)
    end
  end

  private
  def default_options
    {
      environment: :production,
      payload: "pardot",
    }
  end

  def print_help
    readme = File.join(File.dirname(__FILE__), '..', 'README.md')
    if File.exist?(readme)
      Console.log(File.read(readme))
    else
      Console.log("Please refer to the README for usage information")
    end

    exit
  end

  def valid_environment?(env)
    env_sym = env.to_s.downcase.to_sym
    valid_environments.include?(env_sym)
  end

  def valid_environments
    # TODO: should we have long and short names?
    [:production, :staging, :test, :dev, :engagement, :production_dfw]
  end
end
