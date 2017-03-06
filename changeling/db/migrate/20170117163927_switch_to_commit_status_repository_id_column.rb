class SwitchToCommitStatusRepositoryIdColumn < ActiveRecord::Migration[5.0]
  def change
    RepositoryCommitStatus.find_each do |commit_status|
      repository = GithubRepository.find_by!(github_id: commit_status.github_repository_id)
      commit_status.update!(repository_id: repository.id)
    end

    change_column_null :repository_commit_statuses, :repository_id, false
    remove_index :repository_commit_statuses, name: "repository_commit_statuses_unique_idx"
    remove_column :repository_commit_statuses, :github_repository_id
  end
end
