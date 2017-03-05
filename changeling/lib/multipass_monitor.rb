# Monitors multipasses to confirm consistent state with GitHub
class MultipassMonitor
  class QuestionableMultipassError < StandardError; end

  attr_reader :repeat

  def initialize(repeat = true)
    @repeat = repeat
  end

  def self.run
    new.run
  end

  def run
    loop do
      log_questionable

      break unless repeat
      nap
    end
  end

  def nap
    sleep 5 * 60
  end

  def log_questionable
    questionable_multipasses = Multipass.find_questionable

    questionable_multipasses.each do |multipass|
      ActiveSupport::Notifications.instrument("multipass.check_commit_statuses", multipass: multipass)
      Metrics.increment("multipass.monitor.questionable")
      error = QuestionableMultipassError.new("questionable_multipass: #{multipass.id}")
      Rollbar.error error
    end
  end
end
