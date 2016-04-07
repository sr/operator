httpClient = require "scoped-http-client"
github = require('githubot')
PullRequestTableMaker = require './pull_request_table_maker'

class GithubApiWrapper

  pulls: (cb, msg, repos, users) ->
    search_query = 'type:pr+state:open'

    repos_query = ''
    if repos
        for repo in repos
            repos_query += "+repo:pardot/#{repo}"
    else
        repos_query += '+repo:pardot/Pardot'

    search_query += repos_query

    if users
        for user in users
            search_query += "+author:#{user}"

    url = "https://git.dev.pardot.com/api/v3/search/issues?q=#{search_query}"
    console.log url

    github.get url, (pulls) ->
        tableMaker = new PullRequestTableMaker()
        table = tableMaker.createPullRequestTable(pulls['items'])
        cb(table, msg)

module.exports = GithubApiWrapper
