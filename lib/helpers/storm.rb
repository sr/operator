require "logger"
require "shell_helper"

# module to include in the proper environments for required hooks
module StormEnvModule
  extend self

  PROC_KILL_WAIT_TIME = 45
  STORM_BIN = '/opt/storm/current/bin/storm'

  def load_topology(topo, jar)
    Logger.log(:info, "Loading Topology #{topo_name(topo)} : #{topo_class(topo)}")
    if active?(topo)
      Logger.log(:info, "Topology #{topo_name(topo)} 'isactive'; removing...")
      remove_topology(topo)
      Logger.log(:info, "Topology #{topo_name(topo)} removed")
      sleep PROC_KILL_WAIT_TIME + 2
    end
    add_topology(topo, jar)
  end

  private

  def topo_name(full_topo_param)
    "#{full_topo_param}".split(':')[0]
  end

  def topo_class(full_topo_param)
    "#{full_topo_param}".split(':')[1]
  end

  def remove_topology(topo)
    ShellHelper.sudo_execute("#{STORM_BIN} kill #{topo_name(topo)} -w #{PROC_KILL_WAIT_TIME}", "storm")
  end

  def active?(topo)
    is_active = ShellHelper.sudo_execute("#{STORM_BIN} list | grep #{topo_name(topo)} | grep 'ACTIVE' | wc -l", "storm")
    is_active == 1
  end

  def add_topology(topo, jar)
    add_topo_output = ShellHelper.sudo_execute("#{STORM_BIN} jar -c env=prod #{jar} #{topo_class(topo)} #{topo_name(topo)} remote", "storm")
    Logger.log(:info, "Topology Deploy Routine Output:\n#{add_topo_output}" )
  end

end
