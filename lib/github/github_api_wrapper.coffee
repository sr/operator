httpClient = require "scoped-http-client"
github = require('githubot')

class GithubApiWrapper

  pulls: (cb, users) ->
    search_query = 'repo:pardot/Pardot+type:pr+state:open'

    if users
        for user in users
            search_query = search_query + "+author:#{user}"

    url = "https://git.dev.pardot.com/api/v3/search/issues?q=#{search_query}"
    console.log url

    github.get url, (pulls) ->
        cb(pulls)

module.exports = GithubApiWrapper
