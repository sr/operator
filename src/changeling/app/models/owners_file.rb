require "owners"

class OwnersFile
  def initialize(string)
    @teams = parse(string)
  end

  attr_reader :teams

  private

  def parse(string)
    tokens = Owners::Parser.new.parse(string)
    teams = []

    tokens.each do |token, value|
      case token
      when :TEAMNAME
        teams << value[1, value.length]
      else
        next
      end
    end

    teams.uniq
  end
end
