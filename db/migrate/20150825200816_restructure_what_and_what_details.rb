class RestructureWhatAndWhatDetails < ActiveRecord::Migration
  def up
    add_column :deploys, :branch, :string
    add_column :deploys, :tag, :string

    Deploy.reset_column_information

    Deploy.where(what: "branch").update_all("branch = what_details")
    Deploy.where(what: "tag").update_all(["tag = what_details, branch = ?", "master"])

    remove_column :deploys, :what
    remove_column :deploys, :what_details
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
