module Canoe
  module Locking
    def lock_target!
      current_target.locked = true
      current_target.locking_user = current_user
      current_target.save

      cmd_pieces = []
      cmd_pieces << current_target.script_path + "/ship-it.rb"
      cmd_pieces << "--only-lock"
      cmd_pieces << "--user=#{current_user.email}"

      create_lock_history!

      output = `#{cmd_pieces.join(" ")}`
      flash[:notice] = output
    end

    def unlock_target!(with_force=false)
      current_target.locked = false
      current_target.locking_user = nil
      current_target.save

      cmd_pieces = []
      cmd_pieces << current_target.script_path + "/ship-it.rb"
      cmd_pieces << (with_force ? "--force-unlock" : "--unlock")
      cmd_pieces << "--user=#{current_user.email}"

      Lock.create(deploy_target: current_target,
                  auth_user: current_user,
                  locking: false,
                  forced: with_force,
                  )

      output = `#{cmd_pieces.join(" ")}`
      flash[:notice] = output
    end

    def create_lock_history!
      Lock.create(deploy_target: current_target,
                  auth_user: current_user,
                  locking: true,
                  )

      # also flag it on the target
      current_target.locked = true
      current_target.locking_user = current_user
      current_target.save
    end
  end
end