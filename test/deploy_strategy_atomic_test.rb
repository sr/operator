require_relative "test_helper.rb"
require "deploy_strategy_atomic"
require "environment_test"

describe DeployStrategyAtomic do
  before do
    Console.silence!
  end

  describe "#deploy_to_server" do
    before do
      @rsync_mock = mock
      @rsync_mock.stubs(:rsync_command).returns("sudo rsync foo")
      @payload_mock = mock
      @payload_mock.stubs(:name).returns("test")
      @remote_path_choices = %w[/var/www/testA /var/www/testB]
      @payload_mock.stubs(:remote_path_choices).returns(@remote_path_choices)
      @payload_mock.stubs(:remote_current_link).returns("/var/www/current-test")
      @symlink = nil
      ShellHelper.stubs(:execute_shell).returns("(success)")
      @remote_path_choices.each do | remote_path |
        ShellHelper.stubs(:execute_shell)
          .with(){ | cmd | cmd == "ls -l #{@payload_mock.remote_current_link}" && @symlink == remote_path }
          .returns("lrwxr-xr-x  1 julrich  SFDC\Domain Users  10 Jun 10 07:59 #{@payload_mock.remote_current_link} -> #{remote_path}")
      end
      ShellHelper.stubs(:execute_shell)
        .with(){ | cmd | cmd == "ls -l #{@payload_mock.remote_current_link}" && @symlink.nil? }
        .returns("ls: #{@payload_mock.remote_current_link}: No such file or directory")
      # ShellHelper.stubs(:remote)
      #   .with(){ | server_ip, cmd | cmd.match(/ln -sfn +(?<path>\S+) #{@payload_mock.remote_current_link}_new\;mv -T/) && @symlinks[server_ip] = Regexp.last_match[:path] }.returns("")
      ShellHelper.stubs(:execute_shell)
        .with(){ | cmd | cmd.match(/ln -sfn? +(?<path>\S+) #{@payload_mock.remote_current_link}/) && @symlink = Regexp.last_match[:path] }.returns("")
      env = EnvironmentTest.new
      env.stubs(:payload).returns(@payload_mock)
      @strat = DeployStrategyAtomic.new(env)
      @strat.stubs(:fix_index_php)
      @strat.stubs(:rsync).returns(@rsync_mock)
    end

    it "should deploy and link to the first choice when there is no remote_current_link" do
      @strat.deploy("/tmp/foo", %w[localhost])
      assert_equal "/var/www/testA", @symlink, "Did not link to A"
    end

    it "in 3 deploys it should deploy to A/B/A" do
      @strat.deploy("/tmp/foo", "build1000")
      assert_equal "/var/www/testA", @symlink, "Did not link to A"
      @strat.deploy("/tmp/foo", "build1001")
      assert_equal "/var/www/testB", @symlink, "Did not link to B"
      # Don't expect a rollback
      @strat.expects(:extract_artifact)
      @strat.deploy("/tmp/foo", "build1002")
      assert_equal "/var/www/testA", @symlink, "Did not link to A"
    end

    it "should do a rollback" do
      @strat.deploy("/tmp/foo", "build1000")
      assert_equal "/var/www/testA", @symlink, "Did not link to A"
      @strat.deploy("/tmp/foo", "build1001")
      assert_equal "/var/www/testB", @symlink, "Did not link to B"
      @strat.rollback
      assert_equal "/var/www/testA", @symlink, "Did not link to A"
    end

    it "should not roll back because there hasn't been a deploy" do
      refute @strat.rollback?("http://artifactory.example/build1234.tar.gz")
    end

    it "should roll back because the version matches" do
      @strat.deploy("/tmp/foo", "build1000")
      assert_equal "/var/www/testA", @symlink, "Did not link to A"
      @strat.deploy("/tmp/foo", "build1001")
      assert_equal "/var/www/testB", @symlink, "Did not link to B"
      ShellHelper.expects(:execute_shell)
          .with("ls -l #{@payload_mock.remote_current_link}")
          .never
      @strat.deploy("/tmp/foo", "build1000")
      assert_equal "/var/www/testA", @symlink, "Did not link to A"
    end

  end

  describe "#pick_next_choice" do
    # Normally we don't test private methods but just the public ones that call them
    # but this one is a bit tricky so we'll make an exception
    before do
      @strat = DeployStrategyAtomic.new(EnvironmentTest.new)
    end

    it "Basecase" do
      array = []
      current = nil
      pick = @strat.send(:pick_next_choice, array, current, :forward)
      assert_equal nil, pick
    end

    it "Basecase with current" do
      array = []
      current = :a
      pick = @strat.send(:pick_next_choice, array, current, :forward)
      assert_equal nil, pick
    end

    it "Singleton" do
      array = [:a]
      current = :a
      pick = @strat.send(:pick_next_choice, array, current, :forward)
      assert_equal :a, pick
    end

    it "Singleton - Reverse" do
      array = [:a]
      current = :a
      pick = @strat.send(:pick_next_choice, array, current, :reverse)
      assert_equal :a, pick
    end

    it "Middle" do
      array = [:a, :b, :c, :d]
      current = :b
      pick = @strat.send(:pick_next_choice, array, current, :forward)
      assert_equal :c, pick
    end

    it "Middle - Reverse" do
      array = [:a, :b, :c, :d]
      current = :b
      pick = @strat.send(:pick_next_choice, array, current, :reverse)
      assert_equal :a, pick
    end

    it "Wrap Around" do
      array = [:a, :b, :c, :d]
      current = :d
      pick = @strat.send(:pick_next_choice, array, current, :forward)
      assert_equal :a, pick
    end

    it "Wrap Around - Reverse" do
      array = [:a, :b, :c, :d]
      current = :a
      pick = @strat.send(:pick_next_choice, array, current, :reverse)
      assert_equal :d, pick
    end
  end

end
