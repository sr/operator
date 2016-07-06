class GlobalAccountAccess < ActiveRecord::Base
  establish_connection(
    adapter:  "mysql2",
    host:     Datacenter.current_global_config.hostname,
    username: Datacenter.current_global_config.username,
    password: Datacenter.current_global_config.password,
    database: Datacenter.current_global_config.name
  )
  self.table_name = "global_account_access"

  def self.authorized?(account_id)
    where(role: Rails.application.config.x.support_role, account_id: account_id)
      .where("expires_at IS NULL OR expires_at > NOW()").count > 0
  end
end
