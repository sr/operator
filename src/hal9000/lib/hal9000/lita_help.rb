module Lita
  module Handlers
    class Help < Handler
      HELP = Pathname("../../../config/help.txt").expand_path(__FILE__).readlines

      # Monkey-patch https://github.com/litaio/lita/blob/v4.7.1/lib/lita/handlers/help.rb#L11-L18
      def help(response)
        output = build_help(response)
        HELP.each do |line|
          if line.start_with?("#")
            next
          end

          output << line.chomp
        end
        output = filter_help(output, response)
        response.reply_privately output.join("\n")
      end
    end
  end
end
