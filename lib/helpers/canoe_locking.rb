module Canoe
  module Locking
    def lock_target!
      cmd_pieces = []
      cmd_pieces << current_target.script_path + "/ship-it.rb"
      cmd_pieces << current_target.name.downcase
      cmd_pieces << "--only-lock"
      cmd_pieces << "--user=#{current_user.email}"

      current_target.lock!(current_user)

      output = `#{cmd_pieces.join(" ")}`
      flash[:notice] = output
    end

    def unlock_target!(with_force=false)
      cmd_pieces = []
      cmd_pieces << current_target.script_path + "/ship-it.rb"
      cmd_pieces << current_target.name.downcase
      cmd_pieces << (with_force ? "--force-unlock" : "--unlock")
      cmd_pieces << "--user=#{current_user.email}"

      current_target.unlock!(current_user, with_force)

      output = `#{cmd_pieces.join(" ")}`
      flash[:notice] = output
    end
  end
end
