@targets.each do |target|
  json.set! target.name do
    json.locked target.is_locked?
    json.locked_by target.name_of_locking_user
    json.locked_at target.created_at
  end
end
