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
    ensure
      Octokit.auto_paginate = false
    end

    def commits_for_current_repo(count=50)
      Octokit.commits(current_repo.full_name, per_page: count)
    end

    def commits_for_compare(item1, item2)
      return unless item1 && item2
      sha1 = item1.branch? ? item1.sha : item1.what_details
      sha2 = item2.branch? ? item2.sha : item2.what_details
      Octokit.compare(current_repo.full_name, sha1, sha2)
    end

    def committers_for_compare(item1, item2)
      output = commits_for_compare(item1, item2)
      return [] if output.nil?

      # we have to work around stevie's busted git setup (facepalm)
      # gather some sort of author from each commit
      authors = \
        output.commits.collect do |commit|
          commit.author || commit.committer || commit.commit.author || commit.commit.committer
        end
      # try to pull out the username or email (yes, stevie's email is in the name field)
      authors.collect do |author|
        author.try(:login) || author.try(:name)
      end.uniq.sort
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
