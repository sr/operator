require_relative "test_helper.rb"
require "console"

describe Console do
  before do
    reset_class_state!
  end

  describe "class methods" do
    describe "#silence!" do
      it "should silence new instances of console" do
        assert !Console.silent

        Console.silence!
        assert Console.silent
      end
    end

    describe "#log_to" do
      it "should set log path on new instances of console" do
        assert !Console.logging?

        Console.log_to("/tmp/foo.txt")
        assert Console.logging?
        Console.log_path.must_equal("/tmp/foo.txt")
      end
    end

    describe "#no_color" do
      it "should have default of false" do
        refute Console.no_color
      end
    end
  end

  describe "logging" do
    it "should outout content to log file instead of STDOUT" do
      Console.log_to("/tmp/foo.txt")
      STDOUT.expects(:puts).never
      File.expects(:open)
      Console.log("Testing")
    end
  end

  describe "#print_line" do
    it "should print line of -----" do
      STDOUT.expects(:puts).with { |arg| arg.match(/^\+\-\-\-\-\-\-/) }
      Console.print_line
    end
  end

  describe "#log" do
    it "should print for user" do
      output = "This is a test"
      STDOUT.expects(:puts).with { |arg| arg.match(output) }
      Console.log(output)
    end

    it "should colorize string, if requested" do
      output = "This is a test"
      output.expects(:yellow).returns(output)
      STDOUT.expects(:puts).with { |arg| arg.match(output) }
      Console.log(output, :yellow)
    end

    it "should not colorize string, if no_color is set" do
      output = "This is a test"
      Console.no_color = true
      output.expects(:yellow).never
      STDOUT.expects(:puts).with { |arg| arg.match(output) }
      Console.log(output, :yellow)
    end

    it "should ignore unknown colors" do
      output = "This is a test"
      output.expects(:poo_brown).never
      STDOUT.expects(:puts).with { |arg| arg.match(output) }
      Console.log(output, :poo_brown)
    end
  end

  describe "#ask" do
    it "should print out question for user" do
      question = "Do you test?"
      STDOUT.expects(:print).with { |arg| arg.match(question) }
      STDOUT.stubs(:puts) # keep blank line from showing up in output...
      STDIN.expects(:gets).returns("yes")
      Console.ask(question)
    end

    it "should ask question twice if given wrong answer the first time" do
      question = "Do you test?"
      STDOUT.stubs(:puts) # keep blank line from showing up in output...
      STDOUT.expects(:print).with { |arg| arg.match(question) }.twice
      STDIN.expects(:gets).twice.returns("wrong", "yes")
      Console.ask(question, %w[yes no])
    end
  end

  # --------------------------------------------------------------------------
  def reset_class_state!
    %w[silent log_path no_color].each do |var|
      Console.send("#{var}=", nil)
    end
  end

end
