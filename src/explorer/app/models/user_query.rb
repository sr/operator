require "csv"

class UserQuery < ActiveRecord::Base
  class Error < StandardError
  end

  DEFAULT_LIMIT = 10

  belongs_to :user, foreign_key: :user_id

  def for_account?
    account_id.present?
  end

  def account_name
    if !for_account?
      raise Error, "query is not scoped to an account"
    end

    account.descriptive_name
  end

  def executable_query
    query = SQLQuery.parse(raw_sql).limit(DEFAULT_LIMIT)

    if !for_account?
      return query
    end

    query.scope_to(account_id)
  end

  def execute
    database.execute(executable_query.sql)
  end

  def database_tables
    database.tables
  end

  def database_name
    database.name
  end

  private

  def account
    datacenter.find_account(account_id)
  end

  def database
    if for_account?
      datacenter.shard_for(account_id)
    else
      datacenter.global
    end
  end

  def datacenter
    user.datacenter
  end
end
