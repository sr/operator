#!/usr/bin/env ruby

require "sinatra"
require "omniauth"
require "ostruct"
require "pp"

class CanoeApplication < Sinatra::Base
  set :root, File.join(File.dirname(__FILE__), '..')

  # TODO: set secret cookie from ENV
  enable :sessions
  use OmniAuth::Strategies::Developer
  # use OmniAuth::Builder do
  #   provider :developer
  # end

  # ---------------------------------------------------------------
  before do
    authentication_required!
  end

  # ---------------------------------------------------------------
  get "/" do
    erb :index
  end

  get "/login" do
    @oauth_path = "/auth/developer"
    erb :login
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  post "/auth/:name/callback" do
    session.clear
    auth = request.env["omniauth.auth"]
    pp auth

    # TODO: check for salesforce.com address
    # TODO: keep a list of valid email addresses we will accept

    session[:user_id] = auth[:uid]
    redirect "/"
  end


  # ---------------------------------------------------------------
  def current_user
    @_current_user ||= \
      session[:user_id] ? OpenStruct.new(name: 'Shawn', email: 'shawn@veader.org', id: session[:user_id])
                        : nil
  end

  def page_requires_authentication?
    # pages that do not require authentication are login and /auth/... paths
    paths_without_auth = ["/login"]

    ( !paths_without_auth.include?(request.path_info) && \
      !request.path_info.match(%r{^/auth/}) )
  end

  def authentication_required!
    return unless page_requires_authentication?
    redirect "/login" unless current_user
  end

end