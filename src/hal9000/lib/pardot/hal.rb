require "bundler"
require "lita"
require "lita/cli"

module Pardot
  module HAL
    def self.start
      require "pardot/hal/commit_handler"

      Lita::CLI.start
    end
  end
end
