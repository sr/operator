require "conductor"
require "payload"
require "extract_options"
require "underscore_string"
require "yaml"
require "erb"

class EnvironmentBase
  # =========================================================================
  attr_writer :user
  attr_reader :payload

  def initialize
    @user = nil
    load_yaml("environments/#{short_name}.yml.erb")
    load_secrets
  end

  def load_secrets
    if File.exist?(".#{name.underscore}_settings.yml")
      load_yaml(".#{name.underscore}_settings.yml")
    elsif File.exist?(".default_settings.yml")
      load_yaml(".default_settings.yml")
    end
  end

  def self.strategies
    @strategies ||= {}
  end

  def self.hooks
    @hooks ||= Hash.new { |hash, key| hash[key] = Hash.new { |hash1, key1| hash1[key1] = {} } }
  end

  def self.tasks
    @tasks ||= Hash.new { |hash, key| hash[key] = Hash.new { |hash1, key1| hash1[key1] = [] } }
  end

  def self.common_hooks
    @common_hooks ||= \
    begin
      tmp_hooks = Hash.new { |hash, key| hash[key] = Hash.new { |hash1, key1| hash1[key1] = {} } }
      #tmp_hooks[:all][:after][:deploy] = [:log_deploy, :notify_canoe, :announce_deploy_to_hipchat]
      tmp_hooks[:all][:before][:fetch] = [:notify_begin_kibana]
      tmp_hooks[:all][:after][:deploy] = [:notify_complete_kibana, :notify_complete_canoe]
      tmp_hooks[:pardot][:after][:deploy] = [:custom_hooks]
      tmp_hooks
    end
  end

  # Support after_fetch :log_fetch, only: :pardot
  #         before_fetch :log_fetch, only: [:pardot, :pithumbs]
  #         before_deploy [:log_deploy, :announce]
  #         after_deploy [:log_deploy, :announce], only: :pithumbs
  [:before, :after].each do |callback|
    [:fetch, :deploy].each do |action|
      define_singleton_method("#{callback}_#{action}") do |*args|
        options = args.extract_options!
        payloads = begin
          only = Array(options[:only])
          only.empty? ? [:all] : only
        end
        payloads.each do |payload|
          hooks[payload][callback][action] ||= (common_hooks[payload][callback][action] || [])
          hooks[payload][callback][action] |= args.flatten
        end
      end
    end
  end

  # TODO: should we validate strategy????
  [:fetch, :deploy].each do |type|
    define_singleton_method("#{type}_strategy") do |what, strategy, *args|
      options = args.extract_options!
      payloads = begin
        only = Array(options[:only])
        only.empty? ? [:all] : only
      end
      payloads.each do |payload|
        strategies[type][payload] ||= default_strategies(type)
        Array(what).each do |w|
          raise "Unknown fetch type, '#{w}'" unless valid_types.include?(w.to_sym)
          strategies[type][payload][w.to_sym] = strategy.to_sym
        end
      end
    end
  end

  def self.restart_task(*args)
    options = args.extract_options!
    tasks[options.fetch(:only, :all)][:restart].concat(args.map(&:to_sym))
  end

  def self.default_strategies
    {
      deploy: :atomic,
      fetch: :artifactory
    }
  end

  def self.latinize(word)
    d = Hash.new(word)
    d[:before] = :pre
    d[:after] = :post
    d[word]
  end

  # =========================================================================

  # execute_pre_fetch_hooks, execute_post_deploy_hooks,
  # execute_pre_deploy_hooks, execute_post_deploy_hooks, etc
  [:before, :after].each do |callback|
    [:fetch, :deploy].each do |action|
      define_method("execute_#{latinize(callback)}_#{action}_hooks") do |deploy|
        general_hooks = self.class.hooks[:all][callback][action] || self.class.common_hooks[:all][callback][action]
        payload_name = payload.nil? ? :all : payload.id
        payload_hooks = self.class.hooks[payload_name][callback][action] || self.class.common_hooks[payload_name][callback][action]
        callback_hooks = Array(general_hooks) | Array(payload_hooks)

        callback_hooks.each do |method_name|
          method = method(method_name)
          if method.arity == 0
            __send__(method_name)
          elsif method.arity == 1 || method.arity == -1
            __send__(method_name, deploy)
          end
        end
      end
    end
  end

  def execute_restart_tasks(deploy)
    tasks = self.class.tasks[:all][:restart]
    unless payload.nil? || payload.id.nil?
      tasks.concat(self.class.tasks[payload.id][:restart])
    end

    tasks.uniq.each do |method_name|
      m = method(method_name)
      case m.arity.abs
      when 0
        __send__(method_name)
      when 1
        __send__(method_name, deploy)
      end
    end
  end

  def current_fetch_strategy
    current_strategy(:fetch)
  end

  def current_deploy_strategy
    current_strategy(:deploy)
  end

  # =========================================================================
  # common hooks

  # These are per machine custom hooks that are managed by chef
  def custom_hooks
    unless (custom_hooks_path.empty?)
      output = ShellHelper.execute_shell(custom_hooks_path)
      Console.log(output)
    end
  end

  def notify_begin_kibana(deploy)
    Console.syslog("Started fetch of #{payload.name}:#{deploy.what}/#{deploy.what_details} (build#{deploy.build_number})")
  end

  def notify_complete_kibana(deploy)
    Console.syslog("Finished deploy of #{payload.name}:#{deploy.what}/#{deploy.what_details} (build#{deploy.build_number})")
  end

  def notify_complete_canoe(deploy)
    Canoe.notify_server(self, deploy)
  end

  def restart_autojobs
    # Restart automation workers
    Redis.bounce_workers("automationWorkers", autojob_hosts)
    # Restart per account automation workers
    Redis.bounce_workers("PerAccountAutomationWorker", autojob_hosts)
    # Restart related object workers
    Redis.bounce_workers("automationRelatedObjectWorkers", autojob_hosts)
    # Restart automation preview workers
    Redis.bounce_workers("previewWorkers", autojob_hosts)
  end

  def restart_old_style_jobs
    ShellHelper.execute_shell("#{symfony_path}/symfony-#{symfony_env} restart-old-jobs")
  end

  def restart_redis_jobs
    Redis.bounce_redis_jobs("#{symfony_path}/config/services/#{symfony_env}/nosql/redis/client.yml")
  end

  def restart_pithumbs_service
    restart_upstart_job("pithumbs")
  end

  def restart_upstart_job(job)
    result = ShellHelper.execute_shell("sudo /sbin/restart #{job} 2>&1")
    if result.include?("#{job} start/running")
      Console.syslog("Restarted #{job} service")
    elsif result.include?("Unknown instance")
      Console.syslog("#{job} service was not running, attempting start")

      start_result = ShellHelper.execute_shell("sudo /sbin/start #{job} 2>&1")
      if start_result.include?("#{job} start/running")
        Console.syslog("Started #{job} service")
      else
        Console.syslog("Unable to start #{job} service: #{start_result}")
      end
    else
      Console.syslog("Unable to restart #{job} service: #{result}")
    end
  end

  # =========================================================================
  def name
    self.class.to_s.gsub(/^Environment/,"")
  end

  def short_name
    name.underscore # NOTE: redefine in sub-classes if this is shortened (eg: production vs prod)
  end

  # By default, symfony_env is the same as short_name, but it can be overridden in subclasses as needed
  def symfony_env
    short_name
  end

  def conductor
    @conductor ||= Conductor.new(self)
  end

  def user
    ShellHelper.real_user(@user)
  end

  def dev?
    name.underscore == "dev"
  end

  def test_env?
    name.underscore == "test"
  end

  def production?
    name.underscore == "production" || name.underscore == "production_dfw"
  end

  def valid_payload?(payload_name = nil)
    payload_name = payload_name.downcase.to_sym
    if payload_name
      repos.keys.include?(payload_name)
    else
      !payload.nil?
    end
  end

  def payload=(payload_name)
    payload_name = payload_name.downcase.to_sym
    if valid_payload?(payload_name)
      @payload = Payload.new({id: payload_name}.merge(repos[payload_name]))
    end
  end

  def use_canoe?
    !canoe_url.empty?
  end

  # =========================================================================
  # ** Methods used to pull values out of the required env config files

  def repos
    @config[:repos]
  end

  def scripts_path
    SYNC_SCRIPTS_DIR
  end

  def canoe_api_token
    @config.fetch(:canoe_api_token) do
      Console.log("CANOE: No API token specified", :red)
      ""
    end
  end

  def artifactory_user
    @config[:artifactory_user]
  end

  def artifactory_token
    @config[:artifactory_token]
  end

  def canoe_url
    @config.fetch(:canoe_url, "")
  end

  def canoe_target
    @config.fetch(:canoe_target, "")
  end

  def custom_hooks_path
    @config.fetch(:custom_hooks, "")
  end

  def autojob_hosts
    @config.fetch(:autojob_hosts, [])
  end

  def symfony_path
    @config[:symfony_path]
  end

  private

  # Returns our fetch and deploy strategies based on defaults, env specific, and payload specific settings
  # { :tag => :atomic, :commit => :rsync, :branch => :rsync }
  def resolved_strategies
    strategies = self.class.default_strategies
    strategies.merge!(self.class.strategies)
    strategies
  end

  def instantiate_strategy(action, type)
    strategy_require = "#{action}_strategy_#{type}"
    strategy_class = "#{action.to_s.capitalize}Strategy#{type.to_s.capitalize}"
    require strategy_require
    Object.const_get(strategy_class).new(self)
  end

  def current_strategy(action)
    @_strategies ||= {}
    @_strategies[action] ||= instantiate_strategy(action, resolved_strategies[action])
  end

  def load_yaml(filename)
    @config ||= {}
    if filename.nil? || !File.exist?(filename)
      return
    end
    @config.merge!(YAML.load(ERB.new(File.read(filename)).result))
  end

end
