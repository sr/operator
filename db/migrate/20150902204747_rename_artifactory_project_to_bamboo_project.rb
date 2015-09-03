class RenameArtifactoryProjectToBambooProject < ActiveRecord::Migration
  def change
    rename_column :repos, :artifactory_project, :bamboo_project
  end
end
