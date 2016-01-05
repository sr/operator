require 'socket'

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
    Socket.gethostname.sub(/(\.pardot\.com|\.ops\.sfdc\.net)$/, "")
  end

  # this should make it easier to test, etc...
  def self.execute_shell(command)
    IO.popen(command){ |io| io.read.strip }
  end

  def self.sudo_execute(command, user = 'root')
    sudo_command = "sudo -u #{user} #{command}"
    execute_shell(sudo_command)
  end
end
