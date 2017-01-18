class GithubRepository < ApplicationRecord
  self.table_name = "repositories"

  belongs_to :github_installation
  has_many :repository_owners_files, foreign_key: "repository_id"
  has_many :repository_commit_statuses, foreign_key: "repository_id"
  has_many :multipasses, foreign_key: "repository_id"

  delegate :github_client, to: :github_installation

  def full_name
    "#{owner}/#{name}"
  end

  def synchronize
    # The GitHub search API returns empty results when the search backend is
    # unavailable. To avoid syncing bad data, we first perform a query that is
    # known to always return results and abort the synchronization process if it
    # looks like the API is having availability issues.
    if github_client.search_code("user:#{owner} changeling").total_count == 0
      return
    end

    owners_files = []

    query = "in:path filename:#{Repository::OWNERS_FILENAME} repo:#{full_name}"
    results = github_client.search_code(query)

    results.items.each do |item|
      if item.name != Repository::OWNERS_FILENAME
        next
      end

      content = github_client.file_content(full_name, item.path, nil)

      if content.empty?
        next
      end

      path_name =
        if item.path[0] == "/"
          item.path
        else
          "/#{item.path}"
        end

      owners_files << RepositoryOwnersFile.new(
        repository_id: id,
        path_name: path_name,
        content: content
      )
    end

    RepositoryOwnersFile.transaction do
      RepositoryOwnersFile.where(repository_id: id).delete_all
      owners_files.map(&:save!)
    end
  end
end
