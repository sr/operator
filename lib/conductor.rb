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

  def deploy!(label)
    fetch_strategy = environment.current_fetch_strategy
    deploy_strategy = environment.current_deploy_strategy

    if deploy_strategy.rollback?(label)
      return rollback!(deploy_strategy, label)
    end

    unless fetch_strategy.valid?(label)
      invalid_fetch_warning(label)
      return false
    end

    environment.execute_pre_fetch_hooks(label)
    payload_path = fetch_strategy.fetch(label)
    exit_for_invalid_fetch_path if payload_path.empty?
    environment.execute_post_fetch_hooks(label)

    environment.execute_pre_deploy_hooks(label)
    success = deploy_strategy.deploy(payload_path, label)
    environment.execute_post_deploy_hooks(label)

    success
  end

  def rollback!(deploy_strategy, label)
    environment.execute_pre_deploy_hooks(label)
    success = deploy_strategy.rollback
    environment.execute_post_deploy_hooks(label)

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
end