class PullRequestFormatter
	getPrsForUsers: (prs, users) ->
		filteredPrs = []
		for pr in prs
			console.log pr.user.login
			if (pr.user.login in users)
				filteredPrs.push pr
		return filteredPrs

module.exports = PullRequestFormatter
