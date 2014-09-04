class MockDeploy
  attr_accessor :what, :what_details

  def initialize(what, what_details)
    self.what = what
    self.what_details = what_details
  end

  def name
    self.what
  end

  def details
    self.what_details
  end

  def commit?
    self.what == "commit"
  end

end
