require "owners"

class OwnersFile
  User = Struct.new(:github_login)

  def initialize(string)
    @tokens = Owners::Parser.new.parse(string)
  end

  def users
    usernames.map do |username|
      User.new(username)
    end
  end

  private

  def usernames
    usernames = []

    @tokens.each do |token, value|
      if token == :USERNAME
        usernames << value[1, value.length]
      end
    end

    usernames.uniq
  end
end
