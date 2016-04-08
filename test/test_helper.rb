ENV['RAILS_ENV'] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

class ActiveSupport::TestCase
  setup do
    Instrumentation::Logging.reset
    reset_account_access(DataCenter::DALLAS)
  end

  def reset_account_access(datacenter)
    config = DatabaseConfigurationFile.load.global(datacenter)
    connection = Mysql2::Client.new(
      host: config.hostname,
      username: config.username,
      database: config.name
    )
    connection.query("DELETE FROM global_account_access")
  end

  def authorize_access(datacenter, account_id, role = nil)
    role ||= DataCenter::ENGINEERING_ROLE
    database = datacenter.global
    database.execute(<<-SQL, [role, account_id])
      INSERT INTO global_account_access (role, account_id, created_by, expires_at)
      VALUES (?, ?, 1, NOW() + INTERVAL 1 DAY)
    SQL
  end
end
