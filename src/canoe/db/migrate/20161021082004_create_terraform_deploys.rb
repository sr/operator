class CreateTerraformDeploys < ActiveRecord::Migration[5.0]
  def change
    create_table :terraform_deploys do |t|
      t.integer :project_id, null: false
      t.integer :auth_user_id, null: false
      t.string :branch_name, null: false
      t.string :commit_sha1, null: false
      t.string :estate_name, null: false
      t.string :terraform_version, null: false
      t.boolean :successful, null: false, default: false
      t.datetime :completed_at
      t.timestamps
    end

    add_foreign_key :terraform_deploys, :projects
    add_foreign_key :terraform_deploys, :auth_users
  end
end
