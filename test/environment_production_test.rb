require File.join(File.dirname(__FILE__), "test_helper.rb")
require "environment_production"

describe EnvironmentProduction do
  after do
    reset_class_defaults!
  end

  it "should give name as production" do
    env = EnvironmentProduction.new
    env.name.must_equal("Production")
  end

  describe "self.after_fetch" do
    it "should allow setting single hook" do
      EnvironmentProduction.hooks[:all][:after][:fetch].must_be_nil
      EnvironmentProduction.after_fetch :foo
      EnvironmentProduction.hooks[:all][:after][:fetch].must_equal(common_hooks(:after,:fetch) + [:foo])
    end

    it "should allow setting multiple hooks" do
      EnvironmentProduction.hooks[:all][:after][:fetch].must_be_nil
      EnvironmentProduction.after_fetch :bar, :baz
      EnvironmentProduction.hooks[:all][:after][:fetch].must_equal(common_hooks(:after,:fetch) + [:bar, :baz])
    end
  end # ---- self.after_fetch

  # --------------------------------------------------------------------------
  def reset_class_defaults!
    # we need this because we're mucking with class level instance variables
    EnvironmentProduction.instance_variable_set(:@strategies, nil)
    EnvironmentProduction.instance_variable_set(:@hooks, nil)
    EnvironmentProduction.instance_variable_set(:@common_hooks, nil)
  end

  def common_hooks(period,action,payload = :all)
    Array(EnvironmentProduction.common_hooks[payload][period][action])
  end

end
