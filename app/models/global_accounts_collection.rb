class GlobalAccountsCollection
  class NotFound < StandardError
    def initialize(id)
      super "global_account id=#{id.inspect} not found"
    end
  end

  def initialize(user, database)
    @database = database
  end

  def all
    @database.execute(default_query).map do |result|
      GlobalAccount.new(result)
    end
  end

  def find(id)
    sql_query = "#{default_query} WHERE id = ? LIMIT 1"
    results = @database.execute(sql_query, [Integer(id)])

    if results.count.zero?
      raise NotFound, id
    end

    GlobalAccount.new(results.first)
  end

  private

  def default_query
    "SELECT id, shard_id, company FROM global_account"
  end
end
