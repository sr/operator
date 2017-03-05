class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :hostname, null: false
      t.boolean :enabled, null: false, default: true
    end

    add_index :servers, :hostname, unique: true
  end
end
