# Metrics to librato.
# Basic wrapper around methods to add source by default.
module Metrics
  def self.increment(key, args = {})
    metric_name = args.fetch(:prepend_source, true) ? "#{source}.#{key}" : key
    Librato.increment(metric_name, source: source)
  end

  def self.source
    ENV["LIBRATO_SOURCE"]
  end
end
