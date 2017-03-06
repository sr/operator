class CreateDeployNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :deploy_notifications do |t|
      t.integer :project_id, null: false
      t.integer :hipchat_room_id, null: false

      t.timestamps
    end

    add_index :deploy_notifications, [:project_id, :hipchat_room_id], unique: true
  end
end
