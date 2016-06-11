class UserQuery < ActiveRecord::Base
  belongs_to :user, foreign_key: :user_id

  ResultSet = Struct.new(:fields)

  # Returns true if this query is scoped to an account, false otherwise.
  def for_account?
    account_id.present?
  end

  # Returns an empty result set.
  def blank
    ResultSet.new([])
  end

  def secured(current_user)
    SecuredUserQuery.new(current_user, self)
  end
end
