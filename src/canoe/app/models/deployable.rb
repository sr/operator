module Deployable
  def tag?
    what == "tag"
  end

  def branch?
    what == "branch"
  end

  def commit?
    what == "commit"
  end
end
