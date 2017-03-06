# Member of the GitHub SRE Approvers team
# This team changes infrequently and data is cached on disk
# You can fetch it with the following command:
# curl https://api.github.com/teams/1397675/members?access_token=sekret -o config/sres.json
class SREApprover
  attr_reader :github_login, :github_uid

  def initialize(github_uid:, github_login:)
    @github_login = github_login
    @github_uid   = github_uid
  end

  def self.all
    @approvers ||= Config.sres.map do |u|
      new(github_uid: u["id"], github_login: u["login"])
    end
  end

  def self.all=(approvers)
    @approvers = approvers
  end
end
