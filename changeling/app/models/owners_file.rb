require "owners"

class OwnersFile
  def initialize(string)
    @teams, @globs = parse(string)
  end

  attr_reader :teams, :globs

  private

  def parse(string)
    tokens = Owners::Parser.new.parse(string)
    teams = []
    globs = {}
    names = []
    name  = nil

    tokens.each do |token, value|
      case token
      when :NEWLINE
        teams.concat(names)
        names = []
        name = nil
      when :GLOB
        name ||= names.pop
        if name
          globs[value] = name
        end
      when :TEAMNAME
        names << value[1, value.length]
      when :END
        teams.concat(names)
      end
    end

    [teams.uniq, globs]
  end
end
