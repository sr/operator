class CreateTargetJob < ActiveRecord::Migration
  def change
    create_table :target_jobs do |t|
      t.integer :deploy_target_id
      t.integer :auth_user_id
      t.string  :job_name
      t.string  :command
      t.string  :process_id
      t.boolean :completed, default: false
      t.timestamps
    end
    add_index :target_jobs, :deploy_target_id
    add_index :target_jobs, :auth_user_id
  end
end
