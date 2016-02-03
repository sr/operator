require 'canoe'
require 'build_version'
require 'logger'
require 'shell_helper'
require 'environments'

class CLI
  attr_reader :environment

  def initialize(args = ARGV)
    @arguments = args
  end

  def parse_arguments!
    @arguments.each_with_index do |arg, index|
      if %w[help --help -h].include?(arg.downcase)
        print_help
        return
      end

      if index == 0
        begin
          @environment = Environments.build(arg.downcase)
        rescue Environments::NoSuchEnvironment
          Logger.log(:crit, "Invalid environment specified: #{arg}")

          print_help
          return
        end
      elsif index == 1
        # the payload (repository name) MUST be the second argument
        if @environment.valid_payload?(arg)
          @environment.payload = arg
          Logger.context[:payload] = arg
        else
          Logger.log(:crit, "Invalid payload specified: #{arg}")

          print_help
          return
        end
      else
        Logger.log(:crit, "Unknown argument: #{arg}")

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

  def checkin
    current_build_version = BuildVersion.load(environment.payload.build_version_file)

    requested_deploy = Canoe.latest_deploy(environment)
    Logger.context[:deploy_id] = requested_deploy.id

    if requested_deploy.applies_to_this_server?
      if requested_deploy.action == "restart"
        Logger.log(:info, "Executing restart tasks")
        environment.conductor.restart!(requested_deploy)
        Canoe.notify_server(environment, requested_deploy)
      elsif requested_deploy.action == "deploy"
        if current_build_version && current_build_version.instance_of_deploy?(requested_deploy) && !environment.payload['eager_deploy']
          Logger.log(:info, "We are up to date")
          Canoe.notify_server(environment, requested_deploy)
        else
          Logger.log(:info, "Currently deploy: #{current_build_version && current_build_version.artifact_url || "<< None >>"}")
          Logger.log(:info, "Requested deploy: #{requested_deploy.artifact_url}")
          environment.conductor.deploy!(requested_deploy)
        end
      else
        Logger.log(:debug, "Nothing to do for this deploy")
      end
    else
      Logger.log(:debug, "The deploy does not apply to this server")
    end
  end

  private
  def print_help
    readme = File.join(File.dirname(__FILE__), '..', 'README.md')
    if File.exist?(readme)
      puts File.read(readme)
    else
      puts "Please refer to the README for usage information"
    end
  end
end
