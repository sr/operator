class AddMaximumUnavailableToProjectsAndDeploys < ActiveRecord::Migration[5.0]
  def up
    # In the future, it might be nice to have maximium unavailable configured on
    # a per-project+per-target (environment) basis, but we'll start with the
    # simple case.
    add_column :projects, :maximum_unavailable_percentage_per_datacenter, :decimal,
      precision: 5, scale: 2, default: "1.0", null: false
    change_column :deploy_results, :stage, :string, default: "start", null: false
  end

  def down
    remove_column :projects, :maximum_unavailable_percentage_per_datacenter
    change_column :deploy_results, :stage, :string, default: "initiated", null: false
  end
end
