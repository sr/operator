class CreateRepoServers < ActiveRecord::Migration
  def change
    create_table :repo_servers do |t|
      t.integer :repo_id, null: false
      t.integer :server_id, null: false
    end

    add_index :repo_servers, [:repo_id, :server_id], unique: true
  end
end
