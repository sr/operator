class AddMergeCommitShaToMultipasses < ActiveRecord::Migration[5.0]
  def change
    add_column :multipasses, :merge_commit_sha, :string
  end
end
