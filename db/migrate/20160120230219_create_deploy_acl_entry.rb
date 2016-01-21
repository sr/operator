class CreateDeployACLEntry < ActiveRecord::Migration
  def change
    create_table :deploy_acl_entries do |t|
      t.integer :repo_id, null: false
      t.integer :deploy_target_id, null: false
      t.string :acl_type, null: false
      t.text :value, null: false

      t.timestamps null: false
    end

    add_index :deploy_acl_entries, [:deploy_target_id, :repo_id], unique: true
    add_index :deploy_acl_entries, :repo_id
  end
end
