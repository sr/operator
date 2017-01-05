class AddCompliantBuildRequirementToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :compliant_builds_required, :boolean, null: false, default: true
  end
end
