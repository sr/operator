#!/usr/bin/env ruby

require "load_envvars"
require "sinatra"
require "sinatra/activerecord"
require "sinatra/partial"
require "rack-flash"
require "omniauth"
require "omniauth-google-oauth2"
require "ostruct"
require "github"

# models ----
require "auth_user"
require "deploy"
require "target_job"
require "deploy_target"
require "lock"

# helpers ----
require "canoe_authentication"
require "canoe_sinatra_tweaks"
require "canoe_locking"
require "canoe_helpers"
require "canoe_guards"
require "canoe_pagination"
require "canoe_deploy_logic"
require "canoe_api"
require "canoe_git_helpers.rb"

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

  # useful for debugging....
  # set :logging, true
  # set :dump_errors, true
  # set :raise_errors, true
  # set :show_exceptions, true

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
    if ENV["RACK_ENV"] == "production"
      OmniAuth.config.full_host = "https://canoe.pardot.com"
    elsif ENV["RACK_ENV"] == "app.dev"
      OmniAuth.config.full_host = "http://canoe.dev.pardot.com"
    end

    # keys found here: https://cloud.google.com/console
    # under veader@gmail.com account ... :(
    use OmniAuth::Builder do
      provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_SECRET"],
               { name: "google", access_type: "online" }
      # prompt: "consent" # <-- add to hash to "force" reset
    end
    OmniAuth.config.logger = Logger.new("log/canoe.log")
  end

  # ---------------------------------------------------------------
  helpers do
    include Canoe::Helpers
    include Canoe::Pagination
    include Canoe::DeployLogic
    include Canoe::API
    include Canoe::GitHelpers
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
      session[:user_id] = nil
      error_str = "Unable to authenticate."

      user.errors.full_messages.each do |msg|
        error_str += "\n#{msg}"
      end
      flash[:error] = error_str
      redirect "/login"
    end
  end

  get_or_post "/auth/failure" do
    session.clear
    @auth_hash = request.env["omniauth.auth"]
    @failure_message = params[:message]
    erb :auth_failure
  end

  # REPO --------
  get "/repo/:repo_name" do
    guard_against_unknown_repos!
    erb :repo
  end

  get "/repo/:repo_name/tags" do
    guard_against_unknown_repos!
    @tags = tags_for_current_repo
    erb :repo
  end

  get "/repo/:repo_name/branches" do
    guard_against_unknown_repos!
    @branches = branches_for_current_repo

    if params[:search]
      @branches = @branches.find_all { |b| b.name =~ /#{params[:search]}/i }
    end

    erb :repo
  end

  get "/repo/:repo_name/commits" do
    guard_against_unknown_repos!
    @commits = commits_for_current_repo
    erb :repo
  end

  get "/repo/:repo_name/deploy" do
    guard_against_unknown_repos!
    @deploy_type = OpenStruct.new(name: "", details: "")
    %w[tag branch commit].each do |type|
      if params[type]
        @deploy_type.name = type
        @deploy_type.details = params[type]
        break
      end
    end

    @targets = DeployTarget.order(:name)
    erb :deploy
  end

  # TARGET --------
  get "/target/:target_name" do
    guard_against_unknown_targets!
    get_recent_deploys_for_repos
    @total_deploys = current_target.deploys.count
    @deploys = current_target.deploys.order("created_at DESC")    \
                                     .limit(pagination_page_size) \
                                     .offset(pagination_page_size * (current_page - 1))
    erb :target
  end

  get "/target/:target_name/locks" do
    guard_against_unknown_targets!
    get_recent_deploys_for_repos
    @total_locks = current_target.locks.count
    @locks = current_target.locks.order("created_at DESC")    \
                                 .limit(pagination_page_size) \
                                 .offset(pagination_page_size * (current_page - 1))
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

  get "/target/:target_name/jobs" do
    guard_against_unknown_targets!
    get_recent_deploys_for_repos
    @total_jobs = current_target.jobs.count
    @jobs = current_target.jobs.order("created_at DESC")    \
                               .limit(pagination_page_size) \
                               .offset(pagination_page_size * (current_page - 1))
    erb :target
  end

  post "/target/:target_name/reset_database" do
    guard_against_unknown_targets!
    job = current_target.reset_database!(user: current_user)
    if job
      redirect "/job/#{job.id}/watch"
    else
      flash[:notice] = "Sorry, we were unable to start database reset job at this time."
      redirect back
    end
  end

  # DEPLOY --------
  post "/deploy/target/:target_name" do
    deploy_response = deploy!

    if !deploy_response[:error] && deploy_response[:deploy]
      the_deploy = deploy_response[:deploy]
      redirect "/deploy/#{the_deploy.id}/watch"
    else # error
      # missing pieces
      missing_error_codes = \
        [DEPLOYLOGIC_ERROR_NO_REPO, DEPLOYLOGIC_ERROR_NO_TARGET, DEPLOYLOGIC_ERROR_NO_WHAT]
      if missing_error_codes.include?(deploy_response[:reason])
        flash[:notice] = "We did not have everything needed to deploy. Try again."
        redirect back
      end

      # check for invalid
      if deploy_response[:reason] == DEPLOYLOGIC_ERROR_INVALID_WHAT
        flash[:notice] = "Sorry, it appears you specified an unknown #{deploy_response[:what]}."
        redirect back
      end

      # check for locked target, allow user who has it locked to deploy again
      if deploy_response[:reason] == DEPLOYLOGIC_ERROR_UNABLE_TO_DEPLOY
        flash[:notice] = "Sorry, it looks like #{current_target.name} is locked."
        redirect back
      end

    end
  end

  get "/deploy/:deploy_id" do
    current_deploy.check_completed_status!
    erb :deploy_show
  end

  get "/deploy/:deploy_id/watch" do
    current_deploy.check_completed_status!
    @watching = true
    erb :deploy_show
  end

  post "/deploy/:deploy_id/complete" do
    # does not require auth but requires "secret" params #trust
    redirect "/login" unless params[:super_secret] == 'chatty'

    current_deploy.try(:complete!)
    "" # no real need to return since the script can't do anything with it...
  end

  post "/deploy/:deploy_id/mark/complete" do
    if current_deploy
      current_deploy.completed = true
      current_deploy.save!
    end

    redirect "/deploy/#{current_deploy.id}"
  end

  # JOB --------
  get "/job/:job_id" do
    current_job.check_completed_status!
    erb :job
  end

  get "/job/:job_id/watch" do
    current_job.check_completed_status!
    @watching = true
    erb :job
  end

  # ========================================================================
  # API --------
  get "/api/lock/status" do
    content_type :json

    require_api_authentication!

    output = {}
    all_targets.each do |target|
      output[target.name] = { locked: target.is_locked?,
                              locked_by: target.name_of_locking_user,
                              locked_at: target.created_at,
                            }
    end
    output.to_json
  end

  get "/api/status/target/:target_name" do
    content_type :json

    require_api_authentication!
    require_api_target!
    require_api_user!

    # is the target available for deploy?
    if !current_target.user_can_deploy?(current_user)
      user_name = current_target.name_of_locking_user
      { available: false,
        reason: "#{current_target.name} is currently locked by #{user_name}",
      }.to_json
    elsif current_target.active_deploy
      deploy = current_target.active_deploy
      deploy_name = "#{deploy.repo_name} #{deploy.what} #{deploy.what_details}"
      { available: false,
        reason: "#{current_target.name} is currently running deploy of #{deploy_name}.",
      }.to_json
    else
      { available: true }.to_json
    end
  end

  post "/api/lock/target/:target_name" do
    content_type :json

    require_api_authentication!
    require_api_target!
    require_api_user!

    # lock the given target
    output = lock_target!
    current_target.reload!

    { locked: current_target.is_locked?,
      output: output,
    }.to_json
  end

  post "/api/unlock/target/:target_name" do
    content_type :json

    require_api_authentication!
    require_api_target!
    require_api_user!

    # unlock the given target
    output = unlock_target!
    current_target.reload!

    { locked: current_target.is_locked?,
      output: output,
    }.to_json
  end

  post "/api/deploy/target/:target_name" do
    content_type :json

    require_api_authentication!
    require_api_target!
    require_api_user!
    require_api_repo!

    # start deploy on target
    deploy_response = deploy!

    if !deploy_response[:error] && deploy_response[:deploy]
      the_deploy = deploy_response[:deploy]
      { deployed: true,
        status_callback: "/api/status/deploy/#{the_deploy.id}",
      }.to_json
    else # error
      case deploy_response[:reason]
      when DEPLOYLOGIC_ERROR_NO_REPO # should be handled by guard above
          { error: true,
            message: "Unable to deploy. No repo given."
          }.to_json
        when DEPLOYLOGIC_ERROR_NO_TARGET # should be handled by guard above
          { error: true,
            message: "Unable to deploy. No target given."
          }.to_json
        when DEPLOYLOGIC_ERROR_NO_WHAT
          { error: true,
            message: "Unable to deploy. No branch, tag or commit given."
          }.to_json
        when DEPLOYLOGIC_ERROR_UNABLE_TO_DEPLOY
          { error: true,
            message: "#{current_target.name} is currently locked.",
          }.to_json
        when DEPLOYLOGIC_ERROR_INVALID_WHAT
          { error: true,
            message: "Invalid #{deploy_response[:what]} given."
          }.to_json
        else
          { error: true,
            message: "Unable to deploy. Unknown error."
          }.to_json
      end
    end
  end

  get "/api/status/deploy/:deploy_id" do
    content_type :json

    require_api_authentication!

    # get the status of the given deploy
    if current_deploy
      { target: current_deploy.deploy_target.name,
        user: current_deploy.auth_user.email,
        repo: current_deploy.repo_name,
        what: current_deploy.what,
        what_details: current_deploy.what_details,
        completed: current_deploy.completed,
      }.to_json
    else
      { error: true,
        message: "Unable to find requested deploy.",
      }.to_json
    end
  end

end
