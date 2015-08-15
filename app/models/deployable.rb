module Deployable
  def commit?
    self.what == "commit"
  end

  def tag?
    self.what == "tag"
  end

  def branch?
    self.what == "branch"
  end

  def is_valid?
    return false if self.what.blank? || self.what_details.blank?
    return false unless %w[tag commit branch].include?(self.what)

    # look up the SHA for the item being deployed
    return false if self.sha.blank?
    true
  end

  def get_sha
    # return unless self.sha.blank?
    if commit?
      output = Octokit.commit(self.repo_name, self.what_details)
      self.sha = output[:sha]
    elsif tag?
      output = Octokit.ref(self.repo_name, "tags/#{self.what_details}")
      self.sha = output[:object][:sha]
    elsif branch?
      output = Octokit.ref(self.repo_name, "heads/#{self.what_details}")
      self.sha = output[:object][:sha]
    else
      self.sha = nil
    end
  end

end
