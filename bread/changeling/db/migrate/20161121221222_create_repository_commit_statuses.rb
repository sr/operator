class CreateRepositoryCommitStatuses < ActiveRecord::Migration[5.0]
  def up
    create_table :repository_commit_statuses, id: :uuid do |t|
      t.string :sha, null: false
      t.string :context, null: false
      t.text :state, null: false
      t.integer :github_repository_id, null: false
      t.timestamps null: false
    end

    execute "ALTER TABLE repository_commit_statuses ADD CONSTRAINT state_check CHECK (state IN ('pending', 'success', 'failure', 'error'));"

    add_index :repository_commit_statuses, [:sha, :context], :unique => true
  end

  def down
    drop_table :repository_commit_statuses
  end
end
