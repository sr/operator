class MigrateReposToProjects < ActiveRecord::Migration
  def up
    rename_table :repos, :projects
    add_column :projects, :repository, :string
    remove_column :projects, :deploys_via_artifacts
    remove_column :projects, :supports_branch_deploy

    project_model = Class.new(ActiveRecord::Base) do
      self.table_name = "projects"
    end

    project_model.reset_column_information
    project_model.find_each do |project|
      project.repository = "Pardot/#{project.name}"
      project.save!
    end

    change_column :projects, :repository, :string, null: false

    # Relationships
    rename_column :deploy_acl_entries, :repo_id, :project_id
    rename_column :deploy_scenarios, :repo_id, :project_id
    rename_column :deploys, :repo_name, :project_name
    rename_column :locks, :repo_id, :project_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
