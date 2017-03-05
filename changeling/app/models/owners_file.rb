require "owners"

class OwnersFile
  def initialize(string)
    @teams, @globs = parse(string)
  end

  attr_reader :teams

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
        globs[value] ||= []
        globs[value] << name
      when :TEAMNAME
        names << value[1, value.length]
      when :END
        teams.concat(names)
      end
    end

    [teams.uniq, globs]
  end
end
