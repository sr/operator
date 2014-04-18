module Canoe
  module GitHelpers
    # ----------------------------------------------------------------------
    def tags_for_current_repo(count=50)
      tags = Octokit.tags(current_repo.full_name)
      tags = tags.sort_by { |t| t.name.gsub(/^build/,"").to_i }.reverse
      tags[0,count] # we only really care about the most recent X?
    end

    def branches_for_current_repo
      Octokit.auto_paginate = true
      branches = Octokit.branches(current_repo.full_name)
      branches.sort_by(&:name) # may not really be needed...
    end

    def commits_for_current_repo
      Octokit.commits(current_repo.full_name)
    end

  end
end
