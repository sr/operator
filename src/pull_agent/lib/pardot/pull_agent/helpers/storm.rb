module Pardot
  module PullAgent
    # module to include in the proper environments for required hooks
    module Storm
      PROC_KILL_WAIT_TIME = 45
      STORM_BIN = "/opt/storm/current/bin/storm".freeze

      def load_topology(topo, topo_env, jar)
        Logger.log(:info, "Loading Topology #{topo_name(topo)} : #{topo_class(topo)} in environment #{topo_env}")
        if active?(topo)
          remove_topology(topo)
          Logger.log(:info, "Topology #{topo_name(topo)} killed! Waiting #{PROC_KILL_WAIT_TIME} seconds to resume deploy")
          sleep PROC_KILL_WAIT_TIME + 2
        end
        add_topology(topo, topo_env, jar)
      end
      module_function :load_topology

      private

      def topo_name(full_topo_param)
        full_topo_param.to_s.split(":")[0].strip
      end
      module_function :topo_name

      def topo_class(full_topo_param)
        full_topo_param.to_s.split(":")[1].strip
      end
      module_function :topo_class

      def remove_topology(topo)
        ShellHelper.sudo_execute([STORM_BIN, "kill", topo_name(topo), "-w", PROC_KILL_WAIT_TIME.to_s], "storm", err: [:child, :out])
      end
      module_function :remove_topology

      def active?(topo)
        list = ShellHelper.sudo_execute([STORM_BIN, "list"], "storm")
        topo_active = list.each_line.select { |_line| /#{Regexp.escape(topo_name(topo))}\s+ACTIVE/ }.any?
        Logger.log(:info, "Topology #{topo_name(topo)}: active? == #{topo_active}")

        topo_active
      end
      module_function :active?

      def add_topology(topo, topo_env, jar)
        add_topo_command = [STORM_BIN, "jar", "-c", "env=#{topo_env}", jar, "com.pardot.storm.topology.TopologyRunner", "--topo-def=#{topo_class(topo)}", "--name=#{topo_name(topo)}", "--remote"]
        add_topo_output = ShellHelper.sudo_execute(add_topo_command, "storm", err: [:child, :out])
        Logger.log(:info, "Topology Deploy Routine Command:\n#{add_topo_command}\n")
        Logger.log(:info, "Topology Deploy Routine Output:\n#{add_topo_output}\n")
      end
      module_function :add_topology
    end
  end
end
