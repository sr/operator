class CreateDeployTargets < ActiveRecord::Migration
  def change
    create_table :deploy_targets do |t|
      t.string :name
      t.string :script_path
      t.string :lock_path
      t.boolean :locked
      t.integer :locking_user_id
      t.timestamps
    end
    add_index :deploy_targets, :name
  end
end
