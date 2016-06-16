class AddChefDeploys < ActiveRecord::Migration
  def change
    create_table :chef_deploys do |t|
      t.string :branch, null: false
      t.string :build_url, null: false
      t.string :environment, null: false
      t.string :sha, null: false
      t.string :state, null: false
      t.timestamps
    end
  end
end
