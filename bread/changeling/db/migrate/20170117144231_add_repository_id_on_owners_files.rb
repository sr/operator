class AddRepositoryIdOnOwnersFiles < ActiveRecord::Migration[5.0]
  def change
    add_column :repository_owners_files, :repository_id, :integer, null: true
    add_foreign_key :repository_owners_files, :repositories
    add_index :repository_owners_files, [:repository_id, :path_name], unique: true
  end
end
