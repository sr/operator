#!/usr/bin/env ruby

require "load_envvars"
require "sinatra"
require "sinatra/activerecord"
require 'rack-flash'
require "omniauth"
require "ostruct"
# models ----
require "auth_user"

set :database, ENV["DATABASE_URL"]

class CanoeApplication < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  set :root, File.join(File.dirname(__FILE__), "..")

  # enable :sessions # use explicit so we can set session secret
  use Rack::Session::Cookie, {  key: "rack.session",
                                path: "/",
                                expire_after: 2592000,
                                secret: ENV["SESSION_SECRET"],
                              }
                              # domain: 'foo.com',

  use Rack::Flash, :sweep => true

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
    auth_hash = request.env["omniauth.auth"]

    user = AuthUser.find_or_create_by_omniauth(auth_hash)
    if user && user.valid?
      puts "We have user #{user.id}"
      session[:user_id] = user.id

      # redirect to the requested URL if we have one stashed
      # origin = request.env['omniauth.origin']
      # path_for_redirect = \
      #   if !origin.blank? && origin !~ %r{/sessions/new}
      #     origin
      #   else
      #     root_url
      #   end

      redirect "/"
    else
      puts "We did NOT find or create a user!!"
      session[:user_id] = nil
      error_str = 'Unable to authenticate.'

      user.errors.full_messages.each do |msg|
        error_str += "\n#{msg}"
      end
      flash[:error] = error_str
      redirect "/login"
    end
  end


  # ---------------------------------------------------------------
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

  # ---------------------------------------------------------------
  helpers do
    def current_user
      @_current_user ||= \
        session[:user_id] ? AuthUser.where(id: session[:user_id].to_i).first : nil
    end
  end


end