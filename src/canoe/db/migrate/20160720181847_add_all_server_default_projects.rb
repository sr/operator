class AddAllServerDefaultProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :all_servers_default, :boolean, default: true, null: false
  end
end
