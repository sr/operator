class CreateGithubTeamMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :github_team_memberships do |t|
      t.integer :github_installation_id, null: false
      t.integer :github_team_id, null: false
      t.integer :github_user_id, null: false
      t.text :team_slug, null: false
      t.text :user_login, null: false
      t.timestamps null: false
    end

    add_foreign_key "github_team_memberships", "github_installations"

    add_index :github_team_memberships, [:github_installation_id, :github_team_id, :github_user_id],
      name: "github_team_memberships_github_ids_unique_idx",
      unique: true

    add_index :github_team_memberships, [:github_installation_id, :team_slug, :user_login],
      name: "github_team_memberships_github_names_unique_idx",
      unique: true
  end
end
