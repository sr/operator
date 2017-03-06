class ChangeBambooProjectToDeployViaArtifactsFlag < ActiveRecord::Migration
  def change
    remove_column :repos, :bamboo_project, :string
    add_column :repos, :deploys_via_artifacts, :boolean, null: false, default: false
  end
end
