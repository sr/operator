class PardotRepository
  def initialize(nwo)
    @nwo = nwo
  end

  def name_with_owner
    @nwo
  end

  def team
    if @nwo == "Pardot/chef"
      return "Pardot/ops"
    end

    "Pardot/developers"
  end

  def update_github_commit_status?
    false
  end

  def participating?
    true
  end
end
