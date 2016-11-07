describe Pardot::PullAgent::Environments::Production do
  after do
    reset_class_defaults!
  end

  it "should give name as production" do
    env = Pardot::PullAgent::Environments.build(:production)
    expect(env.name).to eq("production")
    expect(env.short_name).to eq("prod")
  end

  describe "self.after_fetch" do
    it "should allow setting single hook" do
      expect(Pardot::PullAgent::Environments::Production.hooks[:all][:after][:fetch]).to be_nil
      Pardot::PullAgent::Environments::Production.after_fetch :foo
      expect(Pardot::PullAgent::Environments::Production.hooks[:all][:after][:fetch]).to eq(common_hooks(:after, :fetch) + [:foo])
    end

    it "should allow setting multiple hooks" do
      expect(Pardot::PullAgent::Environments::Production.hooks[:all][:after][:fetch]).to be_nil
      Pardot::PullAgent::Environments::Production.after_fetch :bar, :baz
      expect(Pardot::PullAgent::Environments::Production.hooks[:all][:after][:fetch]).to eq(common_hooks(:after, :fetch) + [:bar, :baz])
    end
  end

  describe "self.restart_task" do
    it "allows setting a single task" do
      expect(Pardot::PullAgent::Environments::Production.tasks[:all][:restart]).to eq([])
      Pardot::PullAgent::Environments::Production.restart_task :bar
      expect(Pardot::PullAgent::Environments::Production.tasks[:all][:restart]).to eq([:bar])
    end

    it "allows setting multiple tasks" do
      expect(Pardot::PullAgent::Environments::Production.tasks[:all][:restart]).to eq([])
      Pardot::PullAgent::Environments::Production.restart_task :bar, :baz
      expect(Pardot::PullAgent::Environments::Production.tasks[:all][:restart]).to eq([:bar, :baz])
    end
  end

  describe "#restart_autojobs" do
    it "restarts autojob masters found via disco client" do
      env = Pardot::PullAgent::Environments.build(:production)

      disco = instance_double("DiscoveryClient")
      allow(disco).to receive(:service)
        .with("redis-rules-cache-1")
        .and_return([
          {
            "address" => "127.0.0.1",
            "port" => "6379",
            "payload" => {
              "role" => "master"
            }
          }
        ])
      (2..9).each do |i|
        allow(disco).to receive(:service).with("redis-rules-cache-#{i}").and_return([])
      end

      redis = class_spy("::Pardot::PullAgent::Redis")
      env.restart_autojobs(nil, disco, redis)

      expect(redis).to have_received(:bounce_workers).with("PerAccountAutomationWorker", ["127.0.0.1:6379"])
      expect(redis).to have_received(:bounce_workers).with("PerAccountAutomationWorker-timed", ["127.0.0.1:6379"])
      expect(redis).to have_received(:bounce_workers).with("automationRelatedObjectWorkers", ["127.0.0.1:6379"])
      expect(redis).to have_received(:bounce_workers).with("previewWorkers", ["127.0.0.1:6379"])
    end
  end

  # --------------------------------------------------------------------------
  def reset_class_defaults!
    # we need this because we're mucking with class level instance variables
    Pardot::PullAgent::Environments::Production.instance_variable_set(:@strategies, nil)
    Pardot::PullAgent::Environments::Production.instance_variable_set(:@hooks, nil)
    Pardot::PullAgent::Environments::Production.instance_variable_set(:@tasks, nil)
    Pardot::PullAgent::Environments::Production.instance_variable_set(:@common_hooks, nil)
  end

  def common_hooks(period, action, payload = :all)
    Array(Pardot::PullAgent::Environments::Production.common_hooks[payload][period][action])
  end
end
