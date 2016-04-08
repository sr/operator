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
    if !id.respond_to?(:to_int)
      raise ArgumentError, "invalid account id: #{id.inspect}"
    end

    sql_query = "#{default_query} WHERE id = ? LIMIT 1"
    results = @database.execute(sql_query, [id.to_int])

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
