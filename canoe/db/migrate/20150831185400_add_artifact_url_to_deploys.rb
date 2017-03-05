class AddArtifactUrlToDeploys < ActiveRecord::Migration
  def change
    add_column :deploys, :artifact_url, :string, null: true
  end
end
