module Pardot
  module PullAgent
    # module to include in the proper environments for required hooks
    module Storm
      extend self

      PROC_KILL_WAIT_TIME = 45
      STORM_BIN = "/opt/storm/current/bin/storm".freeze

      def load_topology(topo, jar)
        Logger.log(:info, "Loading Topology #{topo_name(topo)} : #{topo_class(topo)}")
        if active?(topo)
          remove_topology(topo)
          Logger.log(:info, "Topology #{topo_name(topo)} killed! Waiting #{PROC_KILL_WAIT_TIME} seconds to resume deploy")
          sleep PROC_KILL_WAIT_TIME + 2
        end
        add_topology(topo, jar)
      end

      private

      def topo_name(full_topo_param)
        full_topo_param.to_s.split(":")[0].strip
      end

      def topo_class(full_topo_param)
        full_topo_param.to_s.split(":")[1].strip
      end

      def remove_topology(topo)
        ShellHelper.sudo_execute([STORM_BIN, "kill", topo_name(topo), "-w", PROC_KILL_WAIT_TIME.to_s], "storm", err: [:child, :out])
      end

      def active?(topo)
        list = ShellHelper.sudo_execute([STORM_BIN, "list"], "storm")
        topo_active = list.each_line.select { |_line| /#{Regexp.escape(topo_name(topo))}\s+ACTIVE/ }.any?
        Logger.log(:info, "Topology #{topo_name(topo)}: active? == #{topo_active}")

        topo_active
      end

      def add_topology(topo, jar)
        add_topo_command = [STORM_BIN, "jar", "-c", "env=prod", jar, "com.pardot.storm.topology.TopologyRunner", "--topo-def=#{topo_class(topo)}", "--name=#{topo_name(topo)}", "--remote"]
        add_topo_output = ShellHelper.sudo_execute(add_topo_command, "storm", err: [:child, :out])
        Logger.log(:info, "Topology Deploy Routine Command:\n#{add_topo_command}\n")
        Logger.log(:info, "Topology Deploy Routine Output:\n#{add_topo_output}\n")
      end
    end
  end
end
