class UserQuery < ActiveRecord::Base
  belongs_to :user, foreign_key: :user_id

  class RateLimited < StandardError
    def initialize(user)
      super "user #{user.email} rate limited"
    end
  end

  def secured(current_user)
    SecuredUserQuery.new(current_user, self)
  end
end
