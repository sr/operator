class AccessLogsController < ApplicationController
  def index
    @logs = AccessLog.all
  end
end
