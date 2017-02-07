class AddUniqueIndexOnGithubInstallations < ActiveRecord::Migration[5.0]
  def change
    add_index :github_installations, :hostname, unique: true
  end
end
