module PullAgent
  # ShellExecutor is a wrapper around ShellHelper to make it easier to
  # mock/stub in tests. Eventually we might want to move the ShellHelper code
  # into this class and delete ShellHelper altogether.
  class ShellExecutor
    def execute(command, opt = {})
      ShellHelper.execute(command, opt)
    end

    def sudo_execute(command, user = "root", opt = {})
      ShellHelper.sudo_execute(command, user, opt)
    end
  end
end
