# HTTP clients
module Clients
  # Interact with pull requests and commit statuses via the GitHub API
  class GitHub
    # https://developer.github.com/early-access/graphql/enum/pullrequestreviewstate/
    REVIEW_APPROVED = "APPROVED".freeze
    REVIEW_CHANGES_REQUESTED = "CHANGES_REQUESTED".freeze

    CommitStatus = Struct.new(:repository_id, :sha, :context, :state)

    class Error < StandardError
    end

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

    # Returns an Array of users that are members of the given organization's teams
    def team_members(organization, team_slugs)
      team_ids = {}
      users = {}

      @client.organization_teams(organization).each do |team|
        team_ids[team.slug] = team.id
      end

      team_slugs.each do |team|
        @client.team_members(team_ids.fetch(team)).each do |member|
          if users.key?(member.id)
            next
          end

          users[member.id] = member
        end
      end

      users.values
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

    def combined_status(name_with_owner, sha)
      @client.combined_status(name_with_owner, sha)
    end

    def pull_request(name_with_owner, number)
      @client.pull_request(name_with_owner, number)
    end

    def search_code(query)
      @client.search_code(query)
    end

    def file_content(name_with_owner, path, branch = nil)
      params = { path: path }
      if branch
        params[:ref] = branch
      end
      file = @client.contents(name_with_owner, params)

      if file.is_a?(Array)
        raise Error, "path #{path.inspect} is not a file"
      end

      if file.encoding != "base64"
        raise Error, "unknown file encoding: #{file.encoding.inspect}"
      end

      Base64.decode64(file.content)
    rescue Octokit::NotFound
      ""
    end

    def pull_request_reviews(name_with_owner, number)
      # TODO: Replace with @client.pull_request_reviews when GitHub Enterprise
      # API supports <https://developer.github.com/v3/pulls/reviews/>
      agent = Mechanize.new
      agent.get("https://#{Changeling.config.github_hostname}/login") do |login_page|
        login_page.form_with(action: "/session") { |f|
          f["login"] = Changeling.config.github_service_account_username
          f["password"] = Changeling.config.github_service_account_password
        }.click_button
      end

      pr_page = agent.get("https://#{Changeling.config.github_hostname}/#{name_with_owner}/pull/#{number}")
      review_action_item = pr_page.css(".mergeability-details .branch-action-item").first
      return [] if review_action_item.nil?

      review_action_item.css(".merge-status-item").flat_map { |msi|
        user_avatar = msi.css("img").first
        next [] if user_avatar.nil?

        user_login = user_avatar["alt"].sub(/\A@/, "")
        text = msi.css(".text-gray").text
        state = \
          case text
          when /approved these changes/
            REVIEW_APPROVED
          else
            REVIEW_CHANGES_REQUESTED
          end

        Hashie::Mash.new(
          user: {
            login: user_login
          },
          state: state
        )
      }
    end
  end
end
