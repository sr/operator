require "conductor"
require "payload"
require "extract_options"
require "yaml"
require "erb"

class EnvironmentBase
  # =========================================================================
  attr_writer :user
  attr_reader :payload

  def initialize
    @user = nil
    load_yaml("environments/#{short_name.downcase}.yml.erb")
    load_secrets
  end

  def load_secrets
    if File.exist?(".#{name}_settings.yml")
      load_yaml(".#{name}_settings.yml")
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

  def self.common_hooks
    @common_hooks ||= \
    begin
      tmp_hooks = Hash.new { |hash, key| hash[key] = Hash.new { |hash1, key1| hash1[key1] = {} } }
      #tmp_hooks[:all][:after][:deploy] = [:log_deploy, :notify_canoe, :announce_deploy_to_hipchat]
      #tmp_hooks[:pardot][:after][:fetch]  = [:run_composer, :tag_build]
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

  def self.default_strategies
    {
      deploy: :atomic,
      fetch: :tarball
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
      define_method("execute_#{latinize(callback)}_#{action}_hooks") do |label|
        general_hooks = self.class.hooks[:all][callback][action] || self.class.common_hooks[:all][callback][action]
        payload_name = payload.nil? ? :all : payload.id
        payload_hooks = self.class.hooks[payload_name][callback][action] || self.class.common_hooks[payload_name][callback][action]
        callback_hooks = Array(general_hooks) | Array(payload_hooks)

        callback_hooks.each do |method|
          # hooks can take no args or all 1
          if self.class.instance_method(method).arity == 1
            self.send(method, label)
          else
            self.send(method)
          end
        end
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
  def name
    self.class.to_s.gsub(/^Environment/,"")
  end

  def short_name
    name # NOTE: redefine in sub-classes if this is shortened (eg: production vs prod)
  end

  def conductor
    @conductor ||= Conductor.new(self)
  end

  def user
    ShellHelper.real_user(@user)
  end

  def valid_payload?(payload_name = nil)
    if payload_name
      repos.keys.include?(payload_name.to_sym)
    else
      !payload.nil?
    end
  end

  def payload=(payload_name)
    payload_name = payload_name.to_sym
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

  def canoe_url
    @config.fetch(:canoe_url, "")
  end

  def canoe_target
    @config.fetch(:canoe_target, "")
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
