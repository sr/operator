class ShellHelper
  def self.shell_user
    execute_shell("whoami")
  end

  def self.user_is_root?(user=nil)
    (user || self.shell_user) == "root"
  end

  def self.real_user(user)
    if self.user_is_root?(user)
      execute_shell("echo $SUDO_USER")
    else
      user || self.shell_user
    end
  end

  def self.hostname
    execute_shell("hostname")
  end

  # this should make it easier to test, etc...
  def self.execute_shell(command)
    # Console.log(command, :purple)
    `#{command}`.chomp
  end

end
