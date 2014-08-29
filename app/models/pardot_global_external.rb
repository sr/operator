class PardotGlobalExternal < ActiveRecord::Base
  self.abstract_class = true

  establish_connection ENV['DB_CONN_GLOBAL']

private
  def after_initialize
    readonly!
  end

end