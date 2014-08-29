class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  ENV['DB_CONN_GLOBAL'] = 'mysql2://pardot:pardot@localhost:3306/pardot_global'
  ENV['DB_CONN_SHARD1'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard1'
  ENV['DB_CONN_SHARD2'] = 'mysql2://pardot:pardot@localhost:3306/pardot_shard2'
end
