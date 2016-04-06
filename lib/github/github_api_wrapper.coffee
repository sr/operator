httpClient = require "scoped-http-client"
github = require('githubot')
PullRequestTableMaker = require './pull_request_table_maker'
PullRequestFormatter = require './pull_request_formatter'

class GithubApiWrapper

  pulls: (cb) ->
    github.get "https://git.dev.pardot.com/api/v3/repos/pardot/Pardot/pulls", (pulls) ->
        formatter = new PullRequestFormatter()
        pulls = formatter.getPrsForUsers(pulls, ['steve-schraudner'])
        tableMaker = new PullRequestTableMaker()
        table = tableMaker.createPullRequestTable(pulls)
        cb(table)

module.exports = GithubApiWrapper
