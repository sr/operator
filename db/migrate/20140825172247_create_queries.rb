class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.integer :user_id
      t.string :database
      t.string :datacenter
      t.integer :account_id
      t.text :sql
      t.string :view
      t.boolean :is_limited, default: true

      t.timestamps
    end
  end
end
