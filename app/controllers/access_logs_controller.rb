class AccessLogsController < ApplicationController
  def index
    @logs = AccessLog.page(params[:page]).order('id DESC')
  end
end
