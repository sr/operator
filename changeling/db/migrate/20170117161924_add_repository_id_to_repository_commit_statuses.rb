class AddRepositoryIdToRepositoryCommitStatuses < ActiveRecord::Migration[5.0]
  def change
    add_column :repository_commit_statuses, :repository_id, :integer, null: true
    add_foreign_key :repository_commit_statuses, :repositories
    add_index :repository_commit_statuses, [:repository_id, :sha, :context], :unique => true, name: "repository_commit_statuses_unique_idx2"
  end
end
