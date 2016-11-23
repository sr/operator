# A Tonitrus event stored as DB record
class Event < ActiveRecord::Base
  belongs_to :multipass, required: false
  belongs_to :user, required: false

  def self.release_sha_for_payload(payload)
    return unless payload["resource"] == "release"
    return unless payload["data"] && payload["data"]["description"]
    message = payload["data"]["description"]
    match = message.match(/Deploy ([a-z0-9]+)/i)
    match && match[1]
  end

  def self.multipass_for_payload(payload)
    release_sha = release_sha_for_payload(payload)
    return unless release_sha
    Multipass.find_by(["release_id LIKE ?", "#{release_sha}%"])
  end

  def self.user_for_payload(payload)
    email = payload.fetch("actor", {})["email"]
    return unless email
    User.for_heroku_email(email)
  end

  def self.app_name_for_payload(payload)
    payload.dig("data", "app", "name") || ""
  end

  def self.new_from_payload(payload)
    new(
      external_id: payload["id"],
      app_name:    app_name_for_payload(payload),
      resource:    payload["resource"],
      action:      payload["action"],
      payload:     payload,
      multipass:   multipass_for_payload(payload),
      release_sha: release_sha_for_payload(payload),
      user:        user_for_payload(payload)
    )
  end

  def initialize(args = {})
    super
    self.payload ||= {}
  end

  def create?
    self.action == "create"
  end

  def release?
    self.resource == "release"
  end

  def release_id
    return unless release?
    message = payload["data"]["description"]
    return unless message
    match = message.match(/Deploy ([a-z0-9]+)/i)
    match && match[1]
  end

  def to_chat_hash
    {
      type: "event",
      app_name: app_name,
      external_id: external_id,
      resource: resource,
      action: action,
      actor: payload_user,
      description: payload_description
    }
  end

  def payload_user
    payload.dig("data", "user", "email") || payload.dig("actor", "email") || "Unknown user"
  end

  def payload_description
    payload.dig("data", "description") || "No description"
  end

  def repo_name
    apps = Clients::Heimdall.new.apps

    app_data = apps.find do |app_details|
      production = app_details.last["heroku_production_name"]
      staging    = app_details.last["heroku_staging_name"]
      app_name == production || app_name == staging
    end

    app_data.last["repository"] if app_data
  end

  def repository
    if multipass
      multipass.repository
    elsif repo_name
      Repository.find(repo_name)
    else
      Repository.find(default_repo_name)
    end
  end

  private

  def default_repo_name
    Changeling.config.default_repo_name
  end
end
