class TerraformBuild
  def initialize(branch, commit, terraform_version)
    @branch = branch
    @commit = commit
    @terraform_version = terraform_version
  end

  attr_reader :branch, :commit, :terraform_version
end
