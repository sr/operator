class Repo
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def full_name
    "Pardot/#{@name}"
  end

  def tags(count = 30)
    Octokit.tags(full_name, per_page: count)
      .sort_by { |t| -t.name.sub(/\Abuild/, "").to_i }
  end

  def tag(name)
    ref = Octokit.ref(full_name, "tags/#{name}")
    if ref
      Octokit.tag(full_name, ref.object.sha)
    else
      nil
    end
  end

  def latest_tag
    tags.first
  end

  def branches
    Octokit.auto_paginate = true
    branches = Octokit.branches(full_name)
    branches.sort_by(&:name) # may not really be needed...
  ensure
    Octokit.auto_paginate = false
  end
end
