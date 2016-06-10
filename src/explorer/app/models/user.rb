class User < ActiveRecord::Base
  has_many :queries, class_name: "UserQuery", foreign_key: :user_id

  # TODO(sr) Add unit test for this
  def self.find_or_create_by_omniauth(auth_hash)
    find_or_initialize_by(uid: auth_hash["uid"]).tap do |user|
      # Mapping from LDAP: https://github.com/intridea/omniauth-ldap/blob/9d36cdb9f3d4da040ab6f7aff54450392b78f5eb/lib/omniauth/strategies/ldap.rb#L7-L21
      user.email = auth_hash["info"]["email"]
      user.name = [auth_hash["info"]["first_name"], auth_hash["info"]["last_name"]].compact.join(" ")
      user.save!
    end
  end

  def account_query(sql, account_id)
    queries.create!(raw_sql: sql, account_id: account_id)
  end

  def global_query(sql)
    queries.create!(raw_sql: sql)
  end

  def global_accounts
    datacenter.accounts
  end

  def access_authorized?
    if Rails.env.development?
      return true
    end

    if new_record?
      return false
    end

    groups = Rails.application.config.x.authorized_ldap_groups
    auth = Canoe::LDAPAuthorizer.new

    auth.user_is_member_of_any_group?(uid, groups)
  end

  def datacenter
    datacenter = Rails.application.config.x.datacenter

    DataCenter.new(datacenter, self, DatabaseConfigurationFile.load)
  end
end
