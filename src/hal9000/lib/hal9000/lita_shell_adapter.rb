require "lita/adapters/shell"

# Monkey-patch https://github.com/litaio/lita/blob/v4.7.1/lib/lita/adapters/shell.rb
# to silence "WARN: This adapter has not implemented #join."
module Lita
  module Adapters
    class Shell < Adapter
      def join(*)
      end
    end
  end
end
