class CreatePullRequestFiles < ActiveRecord::Migration[5.0]
  def up
    create_table :pull_request_files, id: :uuid do |t|
      t.uuid :multipass_id, null: false
      t.text :filename, null: false
      t.text :state, null: false
      t.text :patch, null: false
      t.timestamps null: false
    end

    add_index :pull_request_files, [:multipass_id, :filename], unique: true

    execute "ALTER TABLE pull_request_files ADD CONSTRAINT state CHECK (state IN ('added', 'modified', 'removed', 'renamed'));"
  end

  def down
    drop_table :pull_request_files
  end
end
