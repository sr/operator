class HerokuRepository
  def self.participating_repositories
    Config.repositories
  end

  def self.data
    Rails.cache.fetch("apps.json", expires_in: 1.hour) do
      client.get("/apps.json").body
    end
  end

  def self.components_host
    ENV.fetch("APPS_JSON_HOST", "components-staging.heroku.tools")
  end

  def self.client
    Faraday.new(url: "https://#{components_host}") do |connection|
      connection.headers["Content-Type"] = "application/json"
      connection.basic_auth "x", ENV["APPS_JSON_PASSWORD"]
      connection.use ZipkinTracer::FaradayHandler, components_host
      connection.adapter Faraday.default_adapter
      connection.response :json, content_type: "application/json"
    end
  end

  def initialize(nwo)
    @name_with_owner = nwo
  end

  attr_reader :name_with_owner

  def update_github_commit_status?
    true
  end

  def participating?
    self.class.participating_repositories.include?(name_with_owner)
  end

  def ticket_reference_required?
    false
  end

  def required_testing_statuses
    raise NotImplementedError, "This behaviour is only enabled for Pardot repositories"
  end

  def team
    self.class.data.find do |_name, info|
      if info["repository"] == name_with_owner
        return info["heroku_team_name"] unless info["heroku_team_name"].blank?
      end
    end
    "Unknown"
  end
end
