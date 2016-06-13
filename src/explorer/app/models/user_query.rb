class UserQuery < ActiveRecord::Base
  belongs_to :user, foreign_key: :user_id

  def secured(current_user)
    SecuredUserQuery.new(current_user, self)
  end
end
