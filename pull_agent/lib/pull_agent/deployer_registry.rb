module PullAgent
  NoSuchDeployerError = Class.new(StandardError)

  class DeployerRegistry
    def self.[](project)
      @registry ||= {}
      @registry[project]
    end

    def self.fetch(project, *args)
      @registry ||= {}
      @registry.fetch(project, *args)
    rescue KeyError
      raise NoSuchDeployerError, "no deployer registered for '#{project}'"
    end

    def self.[]=(project, deployer)
      @registry ||= {}
      @registry[project] = deployer
    end
  end
end
