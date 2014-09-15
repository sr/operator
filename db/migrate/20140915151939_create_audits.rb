class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.string :user
      t.integer :query_id

      t.timestamps
    end
  end
end
