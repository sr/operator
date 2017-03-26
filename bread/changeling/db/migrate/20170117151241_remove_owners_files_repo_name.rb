class RemoveOwnersFilesRepoName < ActiveRecord::Migration[5.0]
  def change
    change_column_null :repository_owners_files, :repository_id, false
    remove_index :repository_owners_files, name: "index_repository_owners_files_on_repository_name_and_path_name"
    remove_column :repository_owners_files, :repository_name
  end
end
