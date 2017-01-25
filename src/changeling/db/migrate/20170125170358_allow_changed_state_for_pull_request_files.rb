class AllowChangedStateForPullRequestFiles < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE pull_request_files DROP CONSTRAINT state;"
    execute "ALTER TABLE pull_request_files ADD CONSTRAINT state CHECK (state IN ('added', 'modified', 'changed', 'removed', 'renamed'));"
  end

  def down
    execute "ALTER TABLE pull_request_files DROP CONSTRAINT state;"
    execute "ALTER TABLE pull_request_files ADD CONSTRAINT state CHECK (state IN ('added', 'modified', 'removed', 'renamed'));"
  end
end
