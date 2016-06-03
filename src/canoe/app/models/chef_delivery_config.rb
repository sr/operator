class ChefDeliveryConfig
  def enabled_in?(environment)
    false
  end

  def repo_name
    "Pardot/chef"
  end

  def master_branch
    "master"
  end

  def max_lock_age
    1.hour
  end

  def room_id
    6 # Ops
  end

  def required_successful_contexts
    ["Style and Lint Checks"]
  end
end
