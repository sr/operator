# color_string.rb

class String
  @@_use_html_color_output = false

  def self.using_html_color?
    @@_use_html_color_output
  end

  def self.use_html_color!
    @@_use_html_color_output = true
  end

  # lets add some fun logic to the string class... :)
  def method_missing(method, *args, &block)
    if (accepted_pi_colors.include?(method.to_s))
      self.pi_color_string(method)
    else
      super
    end
  end

  def respond_to?(method, include_private = false)
    accepted_pi_colors.include?(method.to_s) || super
  end

  # -------------------------------------------------------------------------
  def accepted_pi_colors
    %w[red green yellow purple]
  end

  def pi_color_string(color_code)
    color = \
      case color_code.to_sym
      when :red
        self.class.using_html_color? ? "#A00" : "0;31"
      when :green
        self.class.using_html_color? ? "#0A0" : "0;32"
      when :yellow
        self.class.using_html_color? ? "#AA0" : "1;33"
      when :purple
        self.class.using_html_color? ? "#808" : "1;34"
      end

    if self.class.using_html_color?
      html_string =
        "<span style=\"color:#{color};\">#{self.sub(/\n$/,"")}</span>"
      # handle trailing newline
      html_string += "\n" if self.match(/\n$/)
      html_string
    else
      "\e[#{color}m#{self}\e[0m"
    end
  end

end
