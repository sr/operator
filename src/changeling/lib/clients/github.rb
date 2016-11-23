# HTTP clients
module Clients
  # Interact with pull requests and commit statuses via the GitHub API
  class GitHub
    def initialize(token)
      @client = Octokit::Client.new(
        api_endpoint: Changeling.config.github_api_endpoint,
        access_token: token
      )
    end

    # Identify whether we're a herokai or not
    def heroku_org_member?
      @client.orgs.map { |o| o[:login] }.include? "heroku"
    end

    def compliance_status(name_with_owner, sha)
      statuses = @client.statuses(name_with_owner, sha)
      statuses.detect { |status| status["context"] == "heroku/compliance" }
    end

    def compliance_status_exists?(name_with_owner, sha, description, destination_state)
      status = compliance_status(name_with_owner, sha)
      return false if status.nil?
      status.state == destination_state &&
        status.description == description
    end

    def create_pending_commit_status(name_with_owner, sha, options)
      return if compliance_status_exists?(name_with_owner, sha, options[:description], "pending")
      @client.create_status(name_with_owner, sha, "pending", options)
    end

    def create_success_commit_status(name_with_owner, sha, options)
      return if compliance_status_exists?(name_with_owner, sha, options[:description], "success")
      @client.create_status(name_with_owner, sha, "success", options)
    end

    def create_failure_commit_status(name_with_owner, sha, options)
      return if compliance_status_exists?(name_with_owner, sha, options[:description], "failure")
      @client.create_status(name_with_owner, sha, "failure", options)
    end

    def commit_statuses(name_with_owner, sha)
      @client.statuses(name_with_owner, sha)
    end

    def pull_request(name_with_owner, number)
      repository   = @client.repository(name_with_owner)
      pull_request = @client.pull_request(name_with_owner, number)
      HashWithIndifferentAccess.new(repository: repository, pull_request: pull_request)
    end
  end
end
