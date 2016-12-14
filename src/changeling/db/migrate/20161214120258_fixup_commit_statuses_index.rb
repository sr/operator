class FixupCommitStatusesIndex < ActiveRecord::Migration[5.0]
  def up
    remove_index :repository_commit_statuses, [:sha, :context]
    add_index :repository_commit_statuses, [:github_repository_id, :sha, :context], :unique => true, name: "repository_commit_statuses_unique_idx"
  end

  def down
    remove_index :repository_commit_statuses, [:github_repository_id, :sha, :context]
    add_index :repository_commit_statuses, [:sha, :context], :unique => true
  end
end
