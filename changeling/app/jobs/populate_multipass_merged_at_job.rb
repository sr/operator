class PopulateMultipassMergedAtJob < ActiveJob::Base
  queue_as :default

  def perform
    github_client = GithubInstallation.current.github_client

    Multipass.find_each do |multipass|
      if !multipass.merged_at.nil?
        next
      end

      pull_request = github_client.pull_request(
        multipass.repository_name,
        multipass.pull_request_number
      )

      if pull_request.merged_at.nil?
        next
      end

      multipass.update!(merged_at: pull_request.merged_at)
    end
  end
end
