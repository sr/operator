class PardotGlobalExternal < ActiveRecord::Base
  self.abstract_class = true

  private
  def after_initialize
    readonly!
  end

end