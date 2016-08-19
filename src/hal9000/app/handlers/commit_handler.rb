class CommitHandler < ApplicationHandler
  DEFAULT_REPO = "pardot".freeze
  DEFAULT_BRANCH = "master".freeze

  # The <repo> group is optional in this regex, the commit method
  # will set the default repo to 'pardot' if no <repo> is provided
  route(/^commit(?:\s+(?<repo>[a-z0-9\-]+))?\s+(?<sha>[a-f0-9]+)$/i, :commit, command: true, help: {
    "commit (repo)? <commit sha>" => "Responds with the commit url for the given params, repo defaults to pardot"
  })

  # The <sha1> and <repo> groups are optional in this regex. The diff method will
  # default to comparing just <sha2> to pardot master if no <sha1> provided
  route(/^diff(?<repo>[a-z0-9]+)?(?:\s+(?<sha1>[^\s]+))?\s+(?<sha2>[^\s]+)$/i, :diff, command: true, help: {
    "diff(repo) (sha1) <sha2>" => "Responds with the compare url for the given params, repo defaults to pardot"
  })

  def commit(response)
    sha = response.match_data["sha"]
    repo = response.match_data["repo"] || DEFAULT_REPO

    # TODO: create a Hipchat Handler object to push room notifications to send html
    url = "https://git.dev.pardot.com/Pardot/#{repo}/commit/#{sha}"
    response.reply(url)
  end

  def diff(response)
    repo = response.match_data["repo"] || DEFAULT_REPO
    sha1 = response.match_data["sha1"] || DEFAULT_BRANCH
    sha2 = response.match_data["sha2"]

    diff = "#{sha1}...#{sha2}"
    url = "https://git.dev.pardot.com/Pardot/#{repo}/compare/#{diff}?w=1"
    response.reply(url)
  end
end
