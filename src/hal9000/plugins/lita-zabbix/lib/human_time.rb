require "time"

module HumanTime
  def self.parse(str, now: Time.now)
    if /^([+-]?\d+)(d|day|day)$/ =~ str
      Time.now + Regexp.last_match(1).to_i * 60 * 60 * 24
    elsif /^([+-]?\d+)(h|hr|hrs|hour|hours)$/ =~ str
      Time.now + Regexp.last_match(1).to_i * 60 * 60
    elsif /^([+-]?\d+)(m|min|mins|minute|minutes)$/ =~ str
      Time.now + Regexp.last_match(1).to_i * 60
    elsif /^([+-]?\d+)(s|sec|secs|second|seconds)$/ =~ str
      Time.now + Regexp.last_match(1).to_i
    else
      Time.parse(str)
    end
  end
end
