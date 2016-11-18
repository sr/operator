require "sidekiq/web"
require_relative "../../lib/sidekiq_helpers/logging"

class Logfmt < Sidekiq::Logging::Pretty
  def call(severity, time, program_name, message)
    "pid=#{::Process.pid} tid=#{Thread.current.object_id.to_s(36)} context=\"#{context}\" severity=#{severity} #{message}\n"
  end
end

Sidekiq.configure_server do |config|
  Sidekiq.logger.formatter = Logfmt.new
  Rails.logger = Sidekiq::Logging.logger
  config.server_middleware do |chain|
    chain.add SidekiqHelpers::Logging
    # We already count and have activejob
    chain.remove Sidekiq::Middleware::Server::Logging
  end
end
