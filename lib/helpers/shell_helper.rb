require 'socket'

class ShellHelper
  def self.hostname
    Socket.gethostname.sub(/(\.pardot\.com|\.ops\.sfdc\.net)$/, "")
  end

  # this should make it easier to test, etc...
  def self.execute_shell(command)
    # Console.log(command, :purple)
    IO.popen(command){ |io| io.read.strip }
  end

  def self.sudo_execute(command, user = 'root')
    sudo_command = "sudo -u #{user} #{command}"
    execute_shell(sudo_command)
  end
end
