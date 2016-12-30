require "owners"

class OwnersFile
  def initialize(string)
    @users, @teams = parse(string)
  end

  attr_reader :users, :teams

  private

  def parse(string)
    tokens = Owners::Parser.new.parse(string)
    users = []
    teams = []

    tokens.each do |token, value|
      case token
      when :USERNAME
        users << value[1, value.length]
      when :TEAMNAME
        teams << value[1, value.length]
      else
        next
      end
    end

    [users.uniq, teams.uniq]
  end
end
