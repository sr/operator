class GlobalAccount
  def initialize(attributes)
    @id = attributes.fetch(:id)
    @company = attributes.fetch(:company)
    @shard_id = attributes.fetch(:shard_id)
  end

  attr_reader :id, :company, :shard_id

  def descriptive_name
    "#{@company} #{@shard_id}/#{@id}"
  end
end
