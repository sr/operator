class UserQuery < ActiveRecord::Base
  belongs_to :user, foreign_key: :user_id

  class RateLimited < StandardError
    def initialize(user)
      super "user #{user.email} rate limited"
    end
  end

  # Returns a query that can be executed by the given user. Execution is rate
  # limited and written to an audit log.
  def executable(current_user)
    ExecutableUserQuery.new(current_user, self)
  end
end
