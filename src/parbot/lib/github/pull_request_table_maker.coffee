_ = require "underscore"

class PullRequestTableMaker

  createPullRequestTable: (pullRequests) ->
    if pullRequests.length < 1
      "No open pull requests! (excellent)"
    else
      tableMarkup = "<table><tr><td><strong>Title</strong></td><td><strong>User</strong></td><td><strong>URL</strong></td><td><strong>Repo</strong></td><td><strong>Created Date</strong></td></tr>"
      for pr in pullRequests
        tableMarkup = tableMarkup + @tableRow(pr)
      tableMarkup + "</table>"

  tableRow: (pullRequest) ->
    "<tr><td title=\"#{_.escape(pullRequest.title)}\">#{@truncatePullRequestTitle(pullRequest.title)}</td><td>#{pullRequest.user.login}</td><td><a href = \"#{pullRequest.html_url}\">#{pullRequest.number}</a></td><td>#{@extractRepoName(pullRequest.html_url)}</td><td>#{pullRequest.created_at.substring(0, 10)}</td></tr>"

  extractRepoName: (pullRequestUrl) ->
    regex = pullRequestUrl.match(/Pardot\/([A-Za-z-_]+).*/)
    regex[1]

  truncatePullRequestTitle: (title) ->
    if title.length <= 30
      title.substring(0, 29)
    else
      title.substring(0, 26) + "..."

module.exports = PullRequestTableMaker
