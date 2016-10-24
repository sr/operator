class SalesforceAuthenticatorPairing < ActiveRecord::Base
  belongs_to :auth_user
end
