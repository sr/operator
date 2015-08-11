module Canoe
  module Locking
    def lock_target!
      cmd_options = ["--only-lock", "--no-color", "--user=#{current_user.email}"]
      cmd = current_target.shipit_command(cmd_options)

      current_target.lock!(current_user)

      Bundler.with_clean_env do
        output = `#{cmd}`
        flash[:notice] = output
      end
    end

    def unlock_target!(with_force=false)
      cmd_options = ["--user=#{current_user.email}", "--no-color"]
      cmd_options << (with_force ? "--force-unlock" : "--unlock")
      cmd = current_target.shipit_command(cmd_options)

      current_target.unlock!(current_user, with_force)

      Bundler.with_clean_env do
        output = `#{cmd}`
        flash[:notice] = output
      end
    end
  end
end
