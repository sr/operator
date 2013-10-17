#!/usr/bin/env ruby

require "load_envvars"
require "sinatra"
require "sinatra/activerecord"
require "sinatra/partial"
require 'rack-flash'
require "omniauth"
require "omniauth-google-oauth2"
require "ostruct"
require "pp"

require "github"

# models ----
require "auth_user"
require "deploy"
require "deploy_target"
require "lock"

# helpers ----
require "canoe_authentication"
require "canoe_sinatra_tweaks"
require "canoe_locking"
require "canoe_helpers"
require "canoe_guards"

Time.zone = "UTC"
ActiveRecord::Base.default_timezone = :utc

set :database, ENV["DATABASE_URL"]

class CanoeApplication < Sinatra::Base
  include Canoe::Authentication
  include Canoe::Locking
  include Canoe::Guards

  register Sinatra::ActiveRecordExtension
  register Sinatra::Partial
  register Sinatra::GetOrPost

  set :root, ENV["CANOE_DIR"] # File.join(File.dirname(__FILE__), "..")
  set :partial_template_engine, :erb

  # enable :sessions # use explicit so we can set session secret
  use Rack::Session::Cookie, {  key: "rack.session",
                                path: "/",
                                expire_after: 2592000,
                                secret: ENV["SESSION_SECRET"],
                              }

  use Rack::Flash, :sweep => true

  if ENV["RACK_ENV"] == "development"
    use OmniAuth::Strategies::Developer
  else
    # keys found here: https://cloud.google.com/console
    # under veader@gmail.com account ... :(
    use OmniAuth::Builder do
      provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_SECRET"],
               { name: "google", access_type: "online" }
    end
  end

  # ---------------------------------------------------------------
  helpers do
    include Canoe::Helpers
  end

  # ---------------------------------------------------------------
  before do
    authentication_required!
  end

  # ---------------------------------------------------------------
  get "/" do
    erb :index
  end

  get "/login" do
    @oauth_path = ENV["RACK_ENV"] == "development" ? "/auth/developer" : "/auth/google"
    erb :login
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  get_or_post "/auth/:name/callback" do
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

  # REPO --------
  get "/repo/:repo_name" do
    guard_against_unknown_repos!
    erb :repo
  end

  get "/repo/:repo_name/tags" do
    guard_against_unknown_repos!
    @tags = Octokit.tags(current_repo.full_name)
    @tags = @tags.sort_by { |t| t.name.gsub(/^build/,'').to_i }.reverse
    @tags = @tags[0,50] # we only really care about the most recent 50?
    erb :repo
  end

  get "/repo/:repo_name/branches" do
    guard_against_unknown_repos!
    @branches = Octokit.branches(current_repo.full_name)
    @branches = @branches.sort_by(&:name) # may not really be needed...

    if params[:search]
      @branches = @branches.find_all { |b| b.name =~ /#{params[:search]}/i }
    end

    erb :repo
  end

  get "/repo/:repo_name/commits" do
    guard_against_unknown_repos!
    @commits = Octokit.commits(current_repo.full_name)
    erb :repo
  end

  get "/repo/:repo_name/deploy" do
    guard_against_unknown_repos!
    @deploy_type = OpenStruct.new(name: '', details: '')
    %w[tag branch commit].each do |type|
      if params[type]
        @deploy_type.name = type
        @deploy_type.details = params[type]
      end
    end

    @targets = DeployTarget.order(:name)
    erb :deploy
  end

  # TARGET --------
  get "/target/:target_name" do
    guard_against_unknown_targets!
    get_recent_deploys_for_repos
    @deploys = current_target.deploys.order('created_at DESC')
    erb :target
  end

  get "/target/:target_name/locks" do
    guard_against_unknown_targets!
    get_recent_deploys_for_repos
    @locks = current_target.locks.order('created_at DESC')
    erb :target
  end

  post "/target/:target_name/lock" do
    guard_against_unknown_targets!
    lock_target!
    redirect "/target/#{current_target.name}"
  end

  post "/target/:target_name/unlock" do
    guard_against_unknown_targets!
    unlock_target!
    redirect "/target/#{current_target.name}"
  end

  post "/target/:target_name/unlock/force" do
    guard_against_unknown_targets!
    unlock_target!(true)
    redirect "/target/#{current_target.name}"
  end

  # DEPLOY --------
  post "/deploy/target/:target_name" do
    unless current_repo && current_target
      flash[:notice] = "We did not have everything needed to deploy. Try again."
      redirect back
    end

    # check for locked target, allow user who has it locked to deploy again
    if current_target.is_locked? && \
       current_target.locking_user != current_user && \
       current_target.file_lock_user != current_user.email
      flash[:notice] = "Sorry, it looks like #{current_target.name} is locked."
      redirect back
    end

    deploy_type = ''
    cmd_pieces = []
    cmd_pieces << current_target.script_path + "/ship-it.rb"
    cmd_pieces << current_repo.name
    %w[tag branch commit].each do |type|
      if params[type]
        the_type = deploy_type = type
        the_type = "hash" if type == "commit" # commit is called hash in the options
        cmd_pieces << "#{the_type}=#{params[type]}"
      end
    end

    # need to go ahead and create this since we need the ID to pass to ship-it
    deploy = Deploy.create( deploy_target: current_target,
                            auth_user: current_user,
                            repo_name: current_repo.name,
                            what: deploy_type,
                            what_details: params[deploy_type],
                            completed: false,
                            )

    cmd_pieces << "--lock" if params[:lock] == "on"
    cmd_pieces << "--user=#{current_user.email}"
    cmd_pieces << "--deploy-id=#{deploy.id}"
    cmd_pieces << "--no-confirmations"
    cmd_pieces << "&> #{deploy.log_path}"

    create_lock_history! if params[:lock] == "on"

    # fork off process to run this...
    shipit = fork { exec cmd_pieces.join(" ") }
    Process.detach(shipit)

    redirect "/deploy/#{deploy.id}/watch"
  end

  get "/deploy/:deploy_id" do
    erb :deploy_show
  end

  get "/deploy/:deploy_id/watch" do
    erb :watch
  end

  post "/deploy/:deploy_id/complete" do
    # does not require auth but requires "secret" params #trust
    redirect "/login" unless params[:super_secret] == 'chatty'

    if current_deploy
      current_deploy.completed = true
      current_deploy.save!
    end
    '' # no real need to return since the script can't do anything with it...
  end

  post "/deploy/:deploy_id/mark/complete" do
    if current_deploy
      current_deploy.completed = true
      current_deploy.save!
    end

    redirect "/deploy/#{current_deploy.id}"
  end

end