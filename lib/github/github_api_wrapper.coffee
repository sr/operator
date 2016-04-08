httpClient = require "scoped-http-client"
github = require('githubot')
PullRequestTableMaker = require './pull_request_table_maker'

class GithubApiWrapper
  repos: []
  users: []
  states: ['open']
  types: ['pr']

  buildSearchQuery: ->
    search_query = ''

    if not repos
      repos = []

    if not states
      states = ['open']

    if not types
      types = ['pr']

    for type in this.types
      if search_query
        search_query += '+'
      search_query += "type:#{type}"

    for state in this.states
      if search_query
        search_query += '+'
      search_query += "state:#{state}"

    for repo in this.repos
      if search_query
        search_query += '+'
      search_query += "repo:pardot/#{repo}"

    if this.users
      for user in this.users
        if search_query
          search_query += '+'
        search_query += "author:#{user}"

    return search_query

  pulls: (cb, msg) ->
    search_query = @buildSearchQuery()

    url = "https://git.dev.pardot.com/api/v3/search/issues?q=#{search_query}"
    console.log url

    github.get url, (pulls) ->
        tableMaker = new PullRequestTableMaker()
        table = tableMaker.createPullRequestTable(pulls['items'])
        cb(table, msg)

module.exports = GithubApiWrapper
