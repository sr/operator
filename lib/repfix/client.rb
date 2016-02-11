require "net/https"

module Repfix
  class Client
    def initialize(url: "https://repfix.tools.pardot.com")
      @url = url
    end
  end
end
