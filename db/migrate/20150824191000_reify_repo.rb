class ReifyRepo < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string :name, null: false
      t.string :icon, null: false

      t.string :artifactory_project
      t.boolean :supports_branch_deploy, null: false, default: false
    end

    add_index :repos, :name, unique: true
  end
end
