module PullAgent
  class ChefDeploy
    Response = Struct.new(:success, :message)

    CHEF_ENVIRONMENT_FILE = {
      "performance_testing" => "environments/dev.rb",
      "local" => "none"
    }.freeze

    CHEF_NODES_DIR = {
      "perf" => "nodes/dfw/dev/pardot1",
      "local" => "none"
    }.freeze

    def initialize(script, checkout_path, deploy)
      @script = script
      @checkout_path = checkout_path
      @deploy = deploy
    end

    # rubocop:disable Lint/RescueException
    def apply(env, datacenter, hostname)
      chef_environment_file = CHEF_ENVIRONMENT_FILE[datacenter]
      if !chef_environment_file
        return Response.new(false, "Unable to determine location of chef environment file for datacenter: #{datacenter.inspect}")
      end

      nodes_dir = CHEF_NODES_DIR[datacenter]
      if !nodes_dir
        return Response.new(false, "Unable to determine location of chef nodes directory for datacenter: #{datacenter.inspect}")
      end

      command = [
        @script,
        "-d", @checkout_path.to_s,
        "-b", @deploy["branch"],
        "-s", @deploy["sha"],
        "-f", chef_environment_file,
        "-n", nodes_dir,
        "deploy"
      ]
      log = {
        at: "chef",
        hostname: hostname,
        datacenter: datacenter,
        command: command
      }
      Instrumentation.debug(log)

      output = ShellHelper.execute([env] + command)
      if !$?.success?
        return error(output)
      end

      Response.new(true, "")
    rescue Exception
      Instrumentation.log_exception($!, at: "chef-deploy")
      Response.new(false, "#{$!.class} - #{$!.message}")
    end

    private

    def error(message)
      Response.new(false, message)
    end
  end
end
