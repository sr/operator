module Canoe
  module GitHelpers
    # ----------------------------------------------------------------------
    def tags_for_current_repo(count=30)
      tags = Octokit.tags(current_repo.full_name, per_page: count)
      tags = tags.sort_by { |t| t.name.gsub(/^build/,"").to_i }.reverse
      tags
    end

    def branches_for_current_repo
      Octokit.auto_paginate = true
      branches = Octokit.branches(current_repo.full_name)
      branches.sort_by(&:name) # may not really be needed...
    end

    def commits_for_current_repo
      Octokit.commits(current_repo.full_name)
    end

    def full_tag_info(tag)
      ref = Octokit.ref(current_repo.full_name, "tags/#{tag.name}")
      if ref
        Octokit.tag(current_repo.full_name, ref.object.sha)
      else
        nil
      end
    end

  end
end
