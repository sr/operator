require "deployable"

class ProvisionalDeploy
  include Deployable

  attr_accessor :what, :what_details, :repo_name

  def initialize(what, what_details, repo_name)
    self.what = what
    self.what_details = what_details
    self.repo_name = repo_name
  end

  def sha
    @_sha ||= get_sha # defined in Deployable
  end

  def sha=(new_sha)
    @_sha = new_sha
  end

end
