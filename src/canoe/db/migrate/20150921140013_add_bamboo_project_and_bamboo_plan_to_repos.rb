class AddBambooProjectAndBambooPlanToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :bamboo_project, :string, null: true
    add_column :repos, :bamboo_plan, :string, null: true
  end
end
