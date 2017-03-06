class AddReleaseInformation < ActiveRecord::Migration
  def change
    add_column :events, :multipass_id, :uuid, null: true
    add_column :events, :release_sha, :string, null: true
  end
end
