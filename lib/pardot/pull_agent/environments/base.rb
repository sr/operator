module Pardot
  module PullAgent
    module Environments
      class Base
        # =========================================================================
        attr_writer :user
        attr_reader :payload

        def initialize
          @user = nil
          load_yaml(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "environments", "#{short_name}.yml.erb"))
          load_yaml(File.join(File.dirname(__FILE__), "..", "..", "..", "..", ".#{name}_settings.yml"))
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
                else
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
            if m.arity == 0
              __send__(method_name)
            else
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

        def notify_begin_kibana(deploy)
          Logger.log(:info, "Started fetch of #{deploy.what}/#{deploy.what_details} (#{deploy.artifact_url})")
        end

        def notify_complete_kibana(deploy)
          Logger.log(:info, "Finished deploy of #{deploy.what}/#{deploy.what_details} (#{deploy.artifact_url})")
        end

        def notify_complete_canoe(deploy)
          Canoe.notify_server(self, deploy)
        end

        def restart_autojobs(deploy, disco = DiscoveryClient.new, redis = Redis)
          Logger.log(:info, "Querying the disco service to find redis rule cache masters")

          autojob_hosts = (1..9).flat_map { |i|
            disco.service("redis-rules-cache-#{i}").select { |s| s['payload'] && s['payload']['role'] == 'master' }
          }.map { |s| [s['address'], s['port']].join(':') }

          # Restart automation workers
          redis.bounce_workers("automationWorkers", autojob_hosts)
          # Restart per account automation workers
          redis.bounce_workers("PerAccountAutomationWorker", autojob_hosts)
          # Restart timed automation workers
          redis.bounce_workers("PerAccountAutomationWorker-timed", autojob_hosts)
          # Restart related object workers
          redis.bounce_workers("automationRelatedObjectWorkers", autojob_hosts)
          # Restart automation preview workers
          redis.bounce_workers("previewWorkers", autojob_hosts)
        end

        def restart_old_style_jobs
          cmd = ["#{payload.current_link}/symfony-#{symfony_env}", "restart-old-jobs"]
          output = ShellHelper.execute(cmd)
          Logger.log(:info, "Restarted old style jobs (#{cmd}): #{output}")
        end

        def restart_redis_jobs
          Logger.log(:info, "Querying the disco service to find redis job manager masters")

          disco = DiscoveryClient.new
          found = false
          (1..9).each do |i|
            masters = disco.service("redis-job-#{i}").select { |s| s['payload'] && s['payload']['role'] == 'master' }
            masters.each do |master|
              found = true
              Redis.bounce_redis_jobs(master['address'], master['port'])
            end
          end

          unless found
            Logger.log(:warn, "No redis job manager masters were found")
          end
        end

        def restart_pithumbs_service
          restart_upstart_job("pithumbs")
        end

        def restart_workflowstats_service
          restart_upstart_job("workflowstats")
        end

        def deploy_topology(deploy)
          if deploy.options['topology'].nil? || payload.current_link.nil?
            deploy.options['topology'].nil? && Logger.log(:err, "deploy_topology was called, but deploy.options['topology'] was nil!")
            payload.current_link.nil? && Logger.log(:err, "deploy_topology was called, but payload.current_link was nil!")
          else
            # this finds a JAR inside of a tarball blown up and linked-to at the base level
            jarfile = ShellHelper.execute(["find", "#{payload.current_link}/", "-name", "*.jar"]) # trailing slash is necessary
            if jarfile.nil? || jarfile == ""
              Logger.log(:err, "deploy_topology was called, but no jar file containing topologies was found!")
            else
              Logger.log(:info, "Topology Deployment Param: #{deploy.options['topology']}")
              Logger.log(:info, "Topology Deployment JAR: #{jarfile}")
              Storm.load_topology(deploy.options['topology'], jarfile)
              Logger.log(:info, "Topology Deployment Complete!")
            end
          end
        end

        def restart_upstart_job(job)
          result = ShellHelper.execute(["sudo", "/sbin/restart", job], err: [:child, :out])
          if result.include?("#{job} start/running")
            Logger.log(:info, "Restarted #{job} service")
          elsif result.include?("Unknown instance")
            Logger.log(:info, "#{job} service was not running, attempting start")

            start_result = ShellHelper.execute(["sudo", "/sbin/start", job], err: [:child, :out])
            if start_result.include?("#{job} start/running")
              Logger.log(:info, "Started #{job} service")
            else
              Logger.log(:err, "Unable to start #{job} service: #{start_result}")
            end
          else
            Logger.log(:err, "Unable to restart #{job} service: #{result}")
          end
        end

        def link_blue_mesh_env_file
          payload.path_choices.each do |release_dir|
            begin
              FileUtils.ln_s(File.join(payload.repo_path, ".env"), File.join(release_dir, ".env"))
            rescue Errno::EEXIST
              # already exists
            end
          end
        end

        def link_repfix_env_files
          payload.path_choices.each do |release_dir|
            begin
              FileUtils.ln_s(File.join(payload.repo_path, ".envvars_#{name}.rb"), File.join(release_dir, "api", ".envvars_#{name}.rb"))
            rescue Errno::EEXIST
              # already exists
            end

            begin
              FileUtils.ln_s(File.join(payload.repo_path, "env.rb"), File.join(release_dir, "env.rb"))
            rescue Errno::EEXIST
              # already exists
            end
          end
        end

        def link_repfix_shared_folders
          payload.path_choices.each do |release_dir|
            begin
              FileUtils.ln_s(File.join(payload.repo_path, "log"), File.join(release_dir, "log"))
            rescue Errno::EEXIST
              # already exists
            end

            begin
              FileUtils.ln_s(File.join(payload.repo_path, "output"), File.join(release_dir, "output"))
            rescue Errno::EEXIST
              # already exists
            end
          end
        end

        def restart_repfix_service
          pid = File.read("/var/run/repfix/puma.pid").chomp

          # Killing puma with USR1 performs a rolling restart
          output = ShellHelpers.sudo_execute(["kill", "-USR1", pid], "repfix")
          if $?.success?
            Logger.log(:info, "Restarted Repfix Puma server: #{output}")
          else
            Logger.log(:error, "Error restarting Repfix Puma server: #{output}")
          end
        rescue Error::ENOENT
          Logger.log(:info, "Repfix PID file not found. Service might not be started yet")
        end

        # =========================================================================
        def name
          self.class.to_s.split("::").last.underscore
        end

        # By default, the same as name but can be overridden in subclasses if needed
        def short_name
          name
        end

        # By default, symfony_env is the same as short_name, but it can be overridden in subclasses as needed
        def symfony_env
          short_name
        end

        def conductor
          @conductor ||= Conductor.new(self)
        end

        def dev?
          name == "dev"
        end

        def test?
          name == "test"
        end

        def staging?
          name == "staging"
        end

        def production?
          name == "production" || name == "production_dfw"
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
            Logger.log(:warn, "Canoe API token is missing")
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

        def bypass_version_detection?
          payload.bypass_version_detection
        end

        private

        # Returns our fetch and deploy strategies based on defaults, env specific, and payload specific settings
        # { :tag => :atomic, :commit => :rsync, :branch => :rsync }
        def resolved_strategies
          strategies = self.class.default_strategies
          strategies.merge!(self.class.strategies)
          strategies
        end

        def current_strategy(action)
          @_strategies ||= {}
          @_strategies[action] ||= Strategies.build(action, resolved_strategies[action], self)
        end

        def load_yaml(filename)
          @config ||= {}
          if File.file?(filename)
            @config.merge!(YAML.load(ERB.new(File.read(filename)).result))
          end
        end
      end
    end
  end
end
