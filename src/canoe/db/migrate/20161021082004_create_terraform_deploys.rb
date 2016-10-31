class CreateTerraformDeploys < ActiveRecord::Migration[5.0]
  def change
    create_table :terraform_projects do |t|
      t.integer :project_id, null: false
      t.string :name, null: false
      t.timestamps
    end

    add_index :terraform_projects, :project_id, unique: true
    add_index :terraform_projects, :name, unique: true
    add_foreign_key :terraform_projects, :projects

    create_table :terraform_deploys do |t|
      t.integer :terraform_project_id, null: false
      t.integer :auth_user_id, null: false
      t.string :request_id, null: false
      t.string :branch_name, null: false
      t.string :commit_sha1, null: false
      t.string :terraform_version, null: false
      t.boolean :successful, null: false, default: false
      t.datetime :completed_at
      t.timestamps
    end

    add_index :terraform_deploys, :request_id, unique: true
    add_foreign_key :terraform_deploys, :terraform_projects
    add_foreign_key :terraform_deploys, :auth_users
  end
end
