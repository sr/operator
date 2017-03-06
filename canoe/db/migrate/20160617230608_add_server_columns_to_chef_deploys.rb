class AddServerColumnsToChefDeploys < ActiveRecord::Migration
  def change
    add_column :chef_deploys, :datacenter, :text, null: false
    add_column :chef_deploys, :hostname, :text, null: false
  end
end
