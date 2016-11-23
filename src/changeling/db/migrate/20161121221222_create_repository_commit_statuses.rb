class CreateRepositoryCommitStatuses < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE TYPE commit_status_state AS ENUM ('pending', 'success', 'failure', 'error');
    SQL

    create_table :repository_commit_statuses, id: :uuid do |t|
      t.string :sha, null: false
      t.string :context, null: false
      t.column :state, :commit_status_state, null: false
      t.integer :github_repository_id, null: false
      t.timestamps null: false
    end

    add_index :repository_commit_statuses, [:sha, :context], :unique => true
  end

  def down
    drop_table :repository_commit_statuses

    execute <<-SQL
      DROP TYPE commit_status_state
    SQL
  end
end
