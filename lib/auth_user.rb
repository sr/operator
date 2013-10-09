class AuthUser < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, with: /\@salesforce\.com/, message: 'must be @salesforce.com'

  # TODO: keep a list of valid email addresses we will accept

  def self.find_by_omniauth(auth_hash)
    where(email: auth_hash['info']['email']).first
  end

  def self.create_with_omniauth(auth_hash)
    create(email: auth_hash['info']['email'],
           name:  auth_hash['info']['name'],
           uid:   auth_hash['uid'],
           token: auth_hash['credentials'['token']])
  end

  def self.find_or_create_by_omniauth(auth_hash)
    find_by_omniauth(auth_hash) || create_with_omniauth(auth_hash)
  end

end