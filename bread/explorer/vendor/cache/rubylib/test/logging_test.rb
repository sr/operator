require "minitest/autorun"
require "instrumentation"

class LoggingTest < Minitest::Test
  def setup
    Instrumentation::Logging.reset
  end

  def test_logfmt
    Instrumentation.setup("app", "test", log_format: Instrumentation::LOG_LOGFMT)
    Instrumentation.log(boom: "town")
    log = Instrumentation::Logging.entries.pop
    assert_equal "app=app env=test boom=town", log
  end

  def test_logstash
    Instrumentation.setup("app", "test", log_format: Instrumentation::LOG_LOGSTASH)
    Instrumentation.log(boom: "town")
    log = Instrumentation::Logging.entries.pop
    parsed = JSON.load(log)
    assert_equal ["app", "env", "boom", "@timestamp", "@version"], parsed.keys
    assert_equal "app", parsed["app"]
    assert_equal "test", parsed["env"]
  end

  def test_noop
    Instrumentation.setup("app", "test", log_format: Instrumentation::LOG_NOOP)
    Instrumentation.log(boom: "town")
    log = Instrumentation::Logging.entries.pop
    assert_equal({ app: "app", env: "test", boom: "town" }, log)
  end

  def test_log_exception_noop
    Instrumentation.setup("app", "test", log_format: Instrumentation::LOG_NOOP)
    begin
      raise "boomtown"
    rescue RuntimeError
      Instrumentation.log_exception($!, boom: "town")
    end

    log = Instrumentation::Logging.entries.pop
    assert_equal RuntimeError, log[:class]
    assert_equal "boomtown", log[:message]
    assert !log[:site].nil?
  end

  def test_log_exception_logfmt
    Instrumentation.setup("app", "test", log_format: Instrumentation::LOG_LOGFMT)
    begin
      raise "boomtown"
    rescue RuntimeError
      Instrumentation.log_exception($!, boom: "town")
    end

    log = Instrumentation::Logging.entries.pop
    assert log.include?("class=RuntimeError")
    assert log.include?("message=boomtown")
  end
end
