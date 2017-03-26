class AddIndexesToEvents < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :events, :created_at, algorithm: :concurrently
    add_index :events, :app_name, algorithm: :concurrently
  end
end
