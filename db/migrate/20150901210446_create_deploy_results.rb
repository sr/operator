class CreateDeployResults < ActiveRecord::Migration
  def change
    create_table :deploy_results do |t|
      t.integer :server_id, null: false
      t.integer :deploy_id, null: false
      t.string :status, null: false, default: "pending"
      t.text :logs, null: true
    end

    add_index :deploy_results, [:server_id, :deploy_id], unique: true
    add_index :deploy_results, [:deploy_id, :status]
  end
end
