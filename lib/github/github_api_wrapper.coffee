httpClient = require "scoped-http-client"
github = require('githubot')

class GithubApiWrapper

  pulls: (cb) ->
    github.get "https://git.dev.pardot.com/api/v3/repos/pardot/Pardot/pulls", (pulls) ->
        cb(pulls)

module.exports = GithubApiWrapper
