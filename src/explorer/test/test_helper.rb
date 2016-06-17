ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

module ActiveSupport
  class TestCase
    setup do
      reset_logger
      reset_account_access(Datacenter::DALLAS)
    end

    protected

    def create_user(attributes = {})
      default_attributes = {
        uid: SecureRandom.hex,
        name: "boom",
        email: "sr@sfdc.be"
      }
      User.create!(default_attributes.merge(attributes))
    end

    def reset_account_access(datacenter)
      Datacenter.current.global.execute("DELETE FROM global_account_access")
    end

    def reset_logger
      Instrumentation::Logging.reset
    end

    def authorize_access(account_id, role = nil, expires_at = nil)
      role ||= Rails.application.config.x.support_role

      Datacenter.current.global.execute(<<-SQL, [role, account_id, expires_at])
        INSERT INTO global_account_access (role, account_id, created_by, expires_at)
        VALUES (?, ?, 1, ?)
      SQL
    end
  end
end
