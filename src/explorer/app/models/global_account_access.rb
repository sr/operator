class GlobalAccountAccess < ApplicationRecord
  establish_connection(Datacenter.current_activerecord_config)
  self.table_name = "global_account_access"

  def self.authorized?(account_id)
    where(role: Rails.application.config.x.support_role, account_id: account_id)
      .where("expires_at IS NULL OR expires_at > NOW()").count > 0
  end
end
