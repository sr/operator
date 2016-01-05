require "environments"

describe Environments::Production do
  after do
    reset_class_defaults!
  end

  it "should give name as production" do
    env = Environments.build(:production)
    expect(env.name).to eq("production")
    expect(env.short_name).to eq("prod")
  end

  describe "self.after_fetch" do
    it "should allow setting single hook" do
      expect(Environments::Production.hooks[:all][:after][:fetch]).to be_nil
      Environments::Production.after_fetch :foo
      expect(Environments::Production.hooks[:all][:after][:fetch]).to eq(common_hooks(:after,:fetch) + [:foo])
    end

    it "should allow setting multiple hooks" do
      expect(Environments::Production.hooks[:all][:after][:fetch]).to be_nil
      Environments::Production.after_fetch :bar, :baz
      expect(Environments::Production.hooks[:all][:after][:fetch]).to eq(common_hooks(:after,:fetch) + [:bar, :baz])
    end
  end

  describe "self.restart_task" do
    it "allows setting a single task" do
      expect(Environments::Production.tasks[:all][:restart]).to eq([])
      Environments::Production.restart_task :bar
      expect(Environments::Production.tasks[:all][:restart]).to eq([:bar])
    end

    it "allows setting multiple tasks" do
      expect(Environments::Production.tasks[:all][:restart]).to eq([])
      Environments::Production.restart_task :bar, :baz
      expect(Environments::Production.tasks[:all][:restart]).to eq([:bar, :baz])
    end
  end

  # --------------------------------------------------------------------------
  def reset_class_defaults!
    # we need this because we're mucking with class level instance variables
    Environments::Production.instance_variable_set(:@strategies, nil)
    Environments::Production.instance_variable_set(:@hooks, nil)
    Environments::Production.instance_variable_set(:@tasks, nil)
    Environments::Production.instance_variable_set(:@common_hooks, nil)
  end

  def common_hooks(period,action,payload = :all)
    Array(Environments::Production.common_hooks[payload][period][action])
  end
end
