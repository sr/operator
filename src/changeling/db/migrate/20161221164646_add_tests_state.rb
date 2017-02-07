class AddTestsState < ActiveRecord::Migration[5.0]
  def up
    add_column :multipasses, :tests_state, :string, default: "pending", null: false
    execute "ALTER TABLE multipasses ADD CONSTRAINT tests_state_check CHECK (tests_state IN ('pending', 'success', 'failure'));"
  end

  def down
    execute "ALTER TABLE multipasses DROP CONSTRAINT tests_state_check;"
    remove_column :multipasses, :tests_state
  end
end
