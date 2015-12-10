require "syslog"
require "core_ext/color_string"

class Console
  class << self
    attr_writer :silent, :log_path, :no_color

    def silent
      @silent || false 
    end

    def no_color
      @no_color || false
    end

    def log_path
      @log_path.nil? ? "" : @log_path
    end

    def silence!
      @silent = true
    end
  
    def log_to(path)
      @log_path = path
    end

    def logging?
      !log_path.empty?
    end
  
    # ===========================================================================
    def print_line(color=:none)
      log("+"+("-"*80), color)
    end

    def syslog(message, our_priority = :info)
      return if silent
      priority = case our_priority
      when :info
        Syslog::LOG_INFO
      when :warn
        Syslog::LOG_WARNING
      when :alert
        Syslog::LOG_ALERT
      end
      Syslog.open do
        Syslog.log(priority, message)
      end
    end

    def log(message, color=:none)
      return if silent
  
      # colorize string
      message = message.send(color) if !no_color && %w[red green yellow purple].include?(color.to_s)
  
      if logging?
        # TODO: do we need colorized output in log file?
        File.open(File.expand_path(log_path), "w+") { |f| f.puts message }
      else
        STDOUT.puts message
      end
    end
  
    def ask(question, valid_answers=%w[yes no])
      response = ""
      while !valid_answers.include?(response.downcase)
        message = "#{question} (#{valid_answers.join("|")}): "
        message = message.purple unless no_color
        STDOUT.print message
        response = STDIN.gets.chomp
      end
      STDOUT.puts
  
      response
    end
  end
end
