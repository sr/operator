require "console"
require "shell_helper"

# module to include in the proper environments for required hooks
module StormEnvModule
  WAIT_TIME = 45
  STORM_BIN = '/opt/storm/current/bin/storm'

  def load_murdoc
    load_topology('murdoc-topo')
  end

  def load_topology(topo_name)
    if active?(topo_name)
      remove_topology(topo_name)
      sleep WAIT_TIME + 2
    end
    add_topology(topo_name)
  end

  private

  def remove_topology(topo_name)
    ShellHelper.sudo_execute("#{STORM_BIN} kill #{topo_name} -w #{WAIT_TIME}", "storm")
  end

  def active?(topo_name)
    is_active = ShellHelper.sudo_execute("#{STORM_BIN} list | grep #{topo_name} | grep 'ACTIVE' | wc -l", "storm")
    is_active == 1
  end

  def add_topology(topo_name)
    ShellHelper.sudo_execute("#{STORM_BIN} jar -c env=prod #{environment.payload.current_link} #{topo_class(topo_name)} #{topo_name} remote", "storm")
  end

  def topo_class(topo_name)
    case topo_name
    when 'murdoc-topo'
      'murdoc.processing.topology.MurdocTopology'
    when 'action-topo'
      'murdoc.processing.topology.ActionApplicationTopology'
    when 'reporting-topo'
      'murdoc.reporting.topology.MurdocReportingTopology'
    end
end



