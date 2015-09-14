# make sure encoding works properly on the servers...
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

class Conductor
  # attributes usually set by environment
  attr_reader :environment

  def initialize(environment)
    @environment = environment
    @no_questions = false
  end

  def deploy!
    fetch_strategy = environment.current_fetch_strategy
    deploy_strategy = environment.current_deploy_strategy
    buildnum = environment.deploy_options[:buildnum]
    exit_for_missing_buildnum unless buildnum

    if deploy_strategy.rollback?(buildnum)
      return rollback!(deploy_strategy)
    end

    unless fetch_strategy.valid?(buildnum)
      invalid_fetch_warning(buildnum)
      return false
    end

    environment.execute_pre_fetch_hooks
    payload_path = fetch_strategy.fetch(buildnum)
    exit_for_invalid_fetch_path if payload_path.empty?
    environment.execute_post_fetch_hooks

    environment.execute_pre_deploy_hooks
    success = deploy_strategy.deploy(payload_path, buildnum)
    environment.execute_post_deploy_hooks

    success
  end

  def rollback!(deploy_strategy)
    environment.execute_pre_deploy_hooks
    success = deploy_strategy.rollback
    environment.execute_post_deploy_hooks

    success
  end

  def dont_ask!
    @no_questions = true
  end

  def silent?
    @no_questions
  end

  def invalid_fetch_warning(value)
    Console.log("!"*80, :red)
    Console.log("ERROR: Requested \"#{value}\" was not found.\n" + \
                  "Please confirm it was entered correctly and actually exists.", :red)
  end

  def exit_for_invalid_fetch_path
    Console.log("!"*80, :red)
    Console.log("ERROR: No local path available. Maybe check the environment definitions.")
    exit 1 # TODO: should we have different exit codes for different conditions?
  end

  def exit_for_missing_buildnum
    Console.log("!"*80, :red)
    Console.log("ERROR: No build number selected for deploy")
    exit 1 # TODO: should we have different exit codes for different conditions?
  end
end
