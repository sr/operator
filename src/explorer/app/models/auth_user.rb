class AuthUser < ActiveRecord::Base
  AUTHORIZED_LDAP_GROUPS = %w[releasebox]

  # TODO(sr) Add unit test for this
  def self.find_or_create_by_omniauth(auth_hash)
    find_or_initialize_by(uid: auth_hash["uid"]).tap do |user|
      # Mapping from LDAP: https://github.com/intridea/omniauth-ldap/blob/9d36cdb9f3d4da040ab6f7aff54450392b78f5eb/lib/omniauth/strategies/ldap.rb#L7-L21
      user.email = auth_hash["info"]["email"]
      user.name = [auth_hash["info"]["first_name"], auth_hash["info"]["last_name"]].compact.join(" ")
      user.save!
    end
  end

  def datacenter(name = nil)
    name ||= DataCenter.default_name
    DataCenter.new(self, name)
  end

  def access_authorized?
    if Rails.development?
      return true
    end

    if new_record?
      return false
    end

    auth = Canoe::LDAPAuthorizer.new
    auth.user_is_member_of_any_group?(uid, AUTHORIZED_LDAP_GROUPS)
  end
end
