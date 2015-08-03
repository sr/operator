module Canoe
  class Locker
    def lock!(target, user)
      cmd_options = ["--only-lock", "--no-color", "--user=#{user.email}"]
      cmd = target.shipit_command(cmd_options)

      target.lock!(user)
      `#{cmd}`
    end

    def unlock!(target, user, with_force=false)
      cmd_options = ["--user=#{user.email}", "--no-color"]
      cmd_options << (with_force ? "--force-unlock" : "--unlock")
      cmd = target.shipit_command(cmd_options)

      target.unlock!(user, with_force)
      `#{cmd}`
    end
  end
end
