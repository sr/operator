class AddArchivedToServers < ActiveRecord::Migration[5.0]
  def change
    add_column :servers, :archived, :boolean, null: false, default: false
  end
end
