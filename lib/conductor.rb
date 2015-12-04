require 'redis'
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

  def deploy!(deploy)
    fetch_strategy = environment.current_fetch_strategy
    deploy_strategy = environment.current_deploy_strategy

    if deploy_strategy.rollback?(deploy)
      return rollback!(deploy, deploy_strategy)
    end

    unless fetch_strategy.valid?(deploy)
      invalid_fetch_warning(deploy)
      return false
    end

    environment.execute_pre_fetch_hooks(deploy)
    payload_path = fetch_strategy.fetch(deploy)
    exit_for_invalid_fetch_path if payload_path.empty?
    environment.execute_post_fetch_hooks(deploy)

    environment.execute_pre_deploy_hooks(deploy)
    success = deploy_strategy.deploy(payload_path, deploy)
    environment.execute_post_deploy_hooks(deploy) unless success == deploy_strategy::DEPLOY_FAILED

    success
  end

  def rollback!(deploy, deploy_strategy)
    environment.execute_pre_deploy_hooks(deploy)
    success = deploy_strategy.rollback
    environment.execute_post_deploy_hooks(deploy)

    success
  end

  # Executes the restart phase of the deploy. Only performed on one server per
  # deploy.
  def restart!(deploy)
    environment.execute_restart_tasks(deploy)
  end

  def dont_ask!
    @no_questions = true
  end

  def silent?
    @no_questions
  end

  def invalid_fetch_warning(deploy)
    Console.log("!"*80, :red)
    Console.log("ERROR: Requested deploy #{deploy.inspect} was not found.\n" +
      "Please confirm it was entered correctly and actually exists.", :red)
  end

  def exit_for_invalid_fetch_path
    Console.log("!"*80, :red)
    Console.log("ERROR: No local path available. Maybe check the environment definitions.")
    exit 1 # TODO: should we have different exit codes for different conditions?
  end
end
