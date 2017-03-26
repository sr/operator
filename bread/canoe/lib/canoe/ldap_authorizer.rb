require "net/ldap"

module Canoe
  class LDAPAuthorizer
    def initialize(host: ENV["LDAP_HOST"], port: ENV.fetch("LDAP_PORT", 389), base: ENV["LDAP_BASE"], encryption: :start_tls)
      @base = base
      @ldap = Net::LDAP.new(
        host: host,
        port: port,
        encryption: encryption
      )
    end

    def user_is_member_of_any_group?(user_dn, group_cns)
      user_uid = extract_uid_from_dn(user_dn)
      return false unless user_uid

      group_cn_filter = "(|" + Array(group_cns).map { |cn| "(cn=#{escape(cn)})" }.join("") + ")"
      result = @ldap.search(base: @base, filter: "(&(ou:dn:=Group)#{group_cn_filter})").first
      !!(result && result["memberuid"].include?(user_uid))
    end

    def escape(str)
      str.gsub("*", '\2A')
        .gsub("(", '\28')
        .gsub(")", '\29')
        .gsub("\x00", '\00')
    end

    def extract_uid_from_dn(dn)
      if /\Auid=(?<uid>[^,]+),.*#{Regexp.escape(@base)}\z/ =~ dn
        Regexp.last_match("uid")
      end
    end
  end
end
