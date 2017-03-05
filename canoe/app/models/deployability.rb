class Deployability
  attr_reader :reason

  def initialize(permitted, reason)
    @permitted = permitted
    @reason = reason
  end

  def permitted?
    @permitted
  end
end
