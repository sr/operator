class CreateDeploys < ActiveRecord::Migration
  def change
    create_table :deploys do |t|
      t.integer :deploy_target_id
      t.integer :auth_user_id
      t.string :type
      t.string :type_details
      t.boolean :completed
      t.timestamps
    end
    add_index :deploys, :deploy_target_id
  end
end
