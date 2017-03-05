class AddDefaultBranchToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :default_branch, :string, default: "master", null: false
  end
end
