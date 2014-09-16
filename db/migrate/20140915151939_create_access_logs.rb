class CreateAccessLogs < ActiveRecord::Migration
  def change
    create_table :access_logs do |t|
      t.string :user
      t.integer :query_id

      t.timestamps
    end
  end
end
