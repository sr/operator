class CreateRepositories < ActiveRecord::Migration[5.0]
  def change
    create_table :github_installations do |t|
      t.text :hostname, null: false
      t.timestamps null: false
    end

    create_table :repositories do |t|
      t.integer :github_installation_id, null: false
      t.integer :github_id, null: false
      t.integer :github_owner_id, null: false
      t.text :owner, null: false
      t.text :name, null: false
      t.timestamps null: false
      t.datetime :deleted_at, null: true
    end

    add_foreign_key :repositories, :github_installations

    add_index :repositories, [:github_installation_id, :github_owner_id, :github_id],
      name: "repositories_github_ids_unique_idx",
      unique: true
    add_index :repositories, [:github_installation_id, :owner, :name],
      name: "repositories_github_names_unique_idx",
      unique: true
  end
end
