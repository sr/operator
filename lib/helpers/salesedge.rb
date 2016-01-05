require "logger"
require "shell_helper"

# module to include in the proper environments for required hooks
module SalesEdgeEnvModule
  def restart_salesedge
    se = SalesEdge.new
    se.debugging = true
    se.restart!
  end
end

class SalesEdge
  attr_accessor :debugging

  def services
    @_services ||= {
      "rest"      => "4954",
      "ingestion" => "8989",
      "socket-manager" => nil,
    }
  end

  def restart!
    services.each do |service, port|
      # TODO: what should we do if the service didn't start?
      restart_service!(service, port)
    end
  end

  def restart_service!(service, port)
    Logger.log(:info, "Restarting #{service} (#{port})...", :yellow)

    restart_cmd = "sudo -H /sbin/stop  pardot-push-#{service}; " + \
                  "sudo -H /sbin/start pardot-push-#{service}; "
    output = ShellHelper.execute_shell(restart_cmd)
    Logger.log(:debug, output)
    pause_and_wait(15)

    if port
      if did_service_start?(port) # will loop at least 10 times
        Logger.log(:info, "#{service} is up!")
        return true
      else
        Logger.log(:err, "#{service} did not start?!?")
        return false
      end
    else
      return true
    end
  end

  def service_is_up?(port)
    curl_cmd = "curl -s http://localhost:#{port}/health"
    output = ShellHelper.execute_shell(curl_cmd)
    # http://rubular.com/r/CqgqqmgAwZ
    output.match(/\"status\":\s*true/)
  end

  def did_service_start?(port, attempts=10)
    return false if attempts < 1

    if service_is_up?(port)
      return true
    else
      pause_and_wait
      return did_service_start?(port, attempts-1)
    end
  end

  def pause_and_wait(time = 4)
    sleep(time)
  end

end

