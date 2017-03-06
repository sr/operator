class AddEncryptedGitHubTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_github_token, :text
  end
end
